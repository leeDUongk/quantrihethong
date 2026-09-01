-- Bai lab 6 muc 6.6 -- Row Level Security
--
-- Bai toan: bang khachhang chua du lieu nhieu chi nhanh. Moi nguoi chi duoc
-- xem khach hang cua chi nhanh minh. RBAC THUAN KHONG GIAI DUOC: ca hai nguoi
-- cung vai tro, cung can SELECT tren cung mot bang, nhung phai thay hai tap
-- dong khac nhau.

ALTER TABLE khachhang ENABLE ROW LEVEL SECURITY;

-- =====================================================================
-- PHAN A -- CACH LAM SAI (de dang chu thich, sinh vien tu bat len de thu)
-- =====================================================================
-- Y tuong: doc chi nhanh tu mot bien phien.
--
--   CREATE POLICY p_sai ON khachhang FOR SELECT
--     USING (chi_nhanh = current_setting('app.chi_nhanh', true));
--
-- Cach nay CHAY duoc va trinh dien duoc "hai ket qua khac nhau", NHUNG
-- KHONG AN TOAN: chinh nguoi dung go
--     SET app.chi_nhanh = 'HCM';
-- la doc duoc du lieu chi nhanh khac.
--
-- NGUYEN TAC: bien phien do NGUOI DUNG dat la dau vao KHONG TIN CAY,
-- khong duoc dung lam can cu phan quyen. No chi hop le khi nguoi dung cuoi
-- KHONG ket noi thang vao CSDL ma di qua mot tang ung dung tin cay.
--
-- Muc 6.6 cua tai lieu yeu cau sinh vien TU TAY khai thac lo hong nay
-- truoc khi doc phan B. Bo dau "--" o ba dong CREATE POLICY tren de thu.

-- =====================================================================
-- PHAN B -- CACH LAM DUNG: lay chi nhanh tu DANH TINH DANG NHAP
-- =====================================================================

-- B1. Bang anh xa nguoi dung -> chi nhanh.
--     Nguoi dung thuong KHONG doc va KHONG sua duoc bang nay.
-- File nay duoc viet de CHAY LAI DUOC bao nhieu lan cung ra dung ket qua:
--   IF NOT EXISTS / ON CONFLICT / OR REPLACE / DROP ... IF EXISTS.
-- Muc 6.6 cua tai lieu yeu cau go chinh sach dung ra de thu chinh sach sai,
-- roi nap lai file nay de va -- nen tinh chay lai duoc la bat buoc.
CREATE TABLE IF NOT EXISTS nv_chi_nhanh (
  db_user   name        PRIMARY KEY,
  chi_nhanh VARCHAR(10) NOT NULL
);

INSERT INTO nv_chi_nhanh (db_user, chi_nhanh) VALUES
  ('an_MSSV',    'HN'),
  ('binh_MSSV',  'HCM'),
  ('cuong_MSSV', 'HN')
ON CONFLICT (db_user) DO UPDATE SET chi_nhanh = EXCLUDED.chi_nhanh;

-- HAI DONG REVOKE, KHONG PHAI MOT. Day la mot cai bay that:
-- muc 6.4 da chay
--     ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
--       GRANT SELECT ON TABLES TO r_doc_MSSV;
-- nen bang nv_chi_nhanh VUA TAO XONG da TU DONG co SELECT cho r_doc_MSSV.
-- REVOKE ... FROM PUBLIC khong dung toi quyen cap rieng cho role do.
-- Quyen mac dinh la con dao hai luoi: no cap quyen cho ca bang bi mat ma
-- ta vua tao ra, mot cach im lang.
REVOKE ALL ON nv_chi_nhanh FROM PUBLIC;
REVOKE ALL ON nv_chi_nhanh FROM r_doc_MSSV, r_ketoan_MSSV, r_truongphong_MSSV;

-- B2. Ham tra ve chi nhanh cua nguoi DANG dang nhap.
--     SECURITY DEFINER : ham chay voi quyen cua NGUOI TAO (postgres), nen
--                        doc duoc nv_chi_nhanh du nguoi goi khong co quyen.
--     SET search_path   : chan tan cong danh trao bang qua search_path --
--                        lo hong leo thang dac quyen kinh dien cua ham
--                        SECURITY DEFINER.
--
--     PHAI DUNG session_user, KHONG DUOC DUNG current_user.
--     Ben trong mot ham SECURITY DEFINER, current_user chinh la NGUOI SO HUU
--     ham (postgres) chu khong phai nguoi goi -- do dung la y nghia cua
--     SECURITY DEFINER. Neu viet current_user o day thi cau WHERE se tim
--     dong co db_user = 'postgres', khong thay gi, ham tra ve NULL, chinh
--     sach so sanh voi NULL nen KHONG AI THAY DONG NAO. Loi nay im lang:
--     khong bao loi, chi tra ve 0 dong.
--     session_user la nguoi da MO KET NOI -- dung thu ta can.
CREATE OR REPLACE FUNCTION chi_nhanh_cua_toi()
RETURNS VARCHAR
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  SELECT chi_nhanh FROM nv_chi_nhanh WHERE db_user = session_user;
$$;

REVOKE ALL     ON FUNCTION chi_nhanh_cua_toi() FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION chi_nhanh_cua_toi() TO r_doc_MSSV;

-- B3. Chinh sach dua tren HAM, khong dua tren bien phien
-- Go CA HAI chinh sach truoc khi tao lai, de file chay lai duoc.
DROP POLICY IF EXISTS p_sai            ON khachhang;
DROP POLICY IF EXISTS p_doc_chi_nhanh  ON khachhang;

CREATE POLICY p_doc_chi_nhanh ON khachhang
  FOR SELECT
  USING (chi_nhanh = chi_nhanh_cua_toi());

-- B4. Cap quyen SELECT nhu binh thuong -- RLS loc them PHIA SAU
GRANT SELECT ON khachhang TO r_doc_MSSV;

-- =====================================================================
-- KIEM CHUNG  (luu y co -h de EP di qua TCP, bat buoc nhap mat khau)
-- =====================================================================
--   docker compose exec postgres-db psql -h postgres-db -U an_MSSV -d app_MSSV
--       SELECT * FROM khachhang;      -- CHI ra 3 dong Ha Noi
--       SET app.chi_nhanh = 'HCM';    -- go thu lai chieu cu
--       SELECT * FROM khachhang;      -- VAN 3 dong Ha Noi  <-- da va xong
--       SELECT * FROM nv_chi_nhanh;   -- LOI: permission denied
--
--   docker compose exec postgres-db psql -h postgres-db -U binh_MSSV -d app_MSSV
--       SELECT * FROM khachhang;      -- CHI ra 2 dong TP.HCM
--
-- BA LOAI TAI KHOAN BO QUA MOI POLICY: superuser, role co BYPASSRLS, va
-- CHU SO HUU bang. Dang nhap bang postgres se thay TOAN BO dong -- do khong
-- phai loi. Muon rang buoc ca chu so huu:
--     ALTER TABLE khachhang FORCE ROW LEVEL SECURITY;

-- Bai lab 6 muc 6.6 -- Row Level Security
-- Bai toan: cung mot bang khachhang, moi truong chi nhanh chi duoc xem
-- khach hang cua chi nhanh minh. RBAC thuan KHONG giai duoc bai toan nay.

ALTER TABLE khachhang ENABLE ROW LEVEL SECURITY;

-- Chinh sach doc: chi thay dong khop bien phien app.chi_nhanh
CREATE POLICY p_doc_chi_nhanh ON khachhang
  FOR SELECT
  USING (chi_nhanh = current_setting('app.chi_nhanh', true));

-- Cap quyen SELECT nhu binh thuong -- RLS loc them PHIA SAU
GRANT SELECT ON khachhang TO r_doc_MSSV;

-- ----------------------------------------------------------------------
-- KIEM CHUNG: dang nhap bang an_MSSV roi chay
--
--   SET app.chi_nhanh = 'HN';
--   SELECT * FROM khachhang;      -- chi ra khach hang Ha Noi
--
--   SET app.chi_nhanh = 'HCM';
--   SELECT * FROM khachhang;      -- chi ra khach hang TP.HCM
--
-- CUNG MOT CAU LENH, HAI KET QUA KHAC NHAU.
-- Nguoi dung khong biet minh dang bi loc: khong loi, khong canh bao.
-- ----------------------------------------------------------------------
--
-- LUU Y: superuser (postgres) va chu so huu bang BO QUA moi policy.
-- Dang nhap bang postgres se thay TOAN BO dong -- do khong phai loi.
-- Muon rang buoc ca chu so huu:
--     ALTER TABLE khachhang FORCE ROW LEVEL SECURITY;

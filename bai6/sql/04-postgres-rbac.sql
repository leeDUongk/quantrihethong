-- Bai lab 6 muc 6 -- RBAC tren PostgreSQL
-- Chay bang:
--   docker compose exec -T postgres-db psql -U postgres -d app_MSSV < sql/04-postgres-rbac.sql

-- File nay duoc viet de CHAY LAI DUOC bao nhieu lan cung ra dung ket qua.
-- PostgreSQL khong co "CREATE ROLE IF NOT EXISTS", nen phai tu kiem tra
-- trong pg_roles truoc khi tao -- do la viec cua khoi DO $$ ... $$ duoi day.

-- ============ 1. VAI TRO ============
-- PostgreSQL KHONG phan biet user va group -- deu la ROLE.
-- Role khong co LOGIN thi dong vai "nhom".

DO $$
DECLARE r text;
BEGIN
  FOREACH r IN ARRAY ARRAY['r_doc_MSSV','r_ketoan_MSSV','r_truongphong_MSSV'] LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = r) THEN
      EXECUTE format('CREATE ROLE %I', r);
    END IF;
  END LOOP;
END $$;
-- BA TANG QUYEN -- thieu tang nao cung loi
GRANT CONNECT ON DATABASE app_MSSV TO r_doc_MSSV;   -- tang 1
GRANT USAGE   ON SCHEMA public     TO r_doc_MSSV;   -- tang 2  <-- HAY QUEN NHAT
GRANT SELECT  ON hoadon            TO r_doc_MSSV;   -- tang 3
-- QUYEN MUC COT
GRANT SELECT (id, ho_ten, email, phong) ON nhanvien TO r_doc_MSSV;

-- Muc 2: ke thua muc 1
GRANT r_doc_MSSV TO r_ketoan_MSSV;
GRANT INSERT, UPDATE ON hoadon TO r_ketoan_MSSV;
-- Cot SERIAL can quyen tren SEQUENCE, thieu la INSERT bao loi.
-- USAGE la DU cho nextval(). SELECT chi can cho currval() nen KHONG cap
-- -- giu dung nguyen tac dac quyen toi thieu.
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO r_ketoan_MSSV;

-- Muc 3: ke thua muc 2
GRANT r_ketoan_MSSV TO r_truongphong_MSSV;
GRANT DELETE ON hoadon   TO r_truongphong_MSSV;
GRANT SELECT ON nhanvien TO r_truongphong_MSSV;

-- ============ 2. QUYEN CHO BANG TUONG LAI ============
-- DIEU KIEN QUAN TRONG: quyen mac dinh chi ap dung cho bang do DUNG ROLE ghi
-- trong "FOR ROLE" tao ra. Khong ghi FOR ROLE thi mac dinh la role dang chay
-- lenh nay. Bang do role KHAC tao ra se KHONG duoc huong. Quyen mac dinh
-- cung KHONG tu ke thua qua quan he thanh vien giua cac role.
--
-- Trong bai lab, moi bang deu do role "postgres" tao (qua initdb.d):
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
  GRANT SELECT ON TABLES TO r_doc_MSSV;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
  GRANT USAGE ON SEQUENCES TO r_ketoan_MSSV;
-- Khong hoi to cho bang da co truoc do.

-- ============ 3. NGUOI DUNG ============
-- Chua co thi TAO, co roi thi DAT LAI mat khau -- deu ra cung mot trang thai.
DO $$
DECLARE u text; p text;
BEGIN
  FOREACH u IN ARRAY ARRAY['an_MSSV','binh_MSSV','cuong_MSSV'] LOOP
    p := CASE u
           WHEN 'an_MSSV'    THEN 'MatKhau_An_MSSV!'
           WHEN 'binh_MSSV'  THEN 'MatKhau_Binh_MSSV!'
           ELSE                   'MatKhau_Cuong_MSSV!'
         END;
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = u) THEN
      EXECUTE format('ALTER ROLE %I LOGIN PASSWORD %L', u, p);
    ELSE
      EXECUTE format('CREATE ROLE %I LOGIN PASSWORD %L', u, p);
    END IF;
  END LOOP;
END $$;

GRANT r_doc_MSSV         TO an_MSSV;
GRANT r_ketoan_MSSV      TO binh_MSSV;
GRANT r_truongphong_MSSV TO cuong_MSSV;

-- Khac MySQL: KHONG can SET DEFAULT ROLE, vai tro co hieu luc ngay
-- (vi role mac dinh la INHERIT).

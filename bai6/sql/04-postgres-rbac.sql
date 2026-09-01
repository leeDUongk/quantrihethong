-- Bai lab 6 muc 6 -- RBAC tren PostgreSQL
-- Chay bang:
--   docker compose exec -T postgres-db psql -U postgres -d app_MSSV < sql/04-postgres-rbac.sql

-- ============ 1. VAI TRO ============
-- PostgreSQL KHONG phan biet user va group -- deu la ROLE.
-- Role khong co LOGIN thi dong vai "nhom".

CREATE ROLE r_doc_MSSV;
-- BA TANG QUYEN -- thieu tang nao cung loi
GRANT CONNECT ON DATABASE app_MSSV TO r_doc_MSSV;   -- tang 1
GRANT USAGE   ON SCHEMA public     TO r_doc_MSSV;   -- tang 2  <-- HAY QUEN NHAT
GRANT SELECT  ON hoadon            TO r_doc_MSSV;   -- tang 3
-- QUYEN MUC COT
GRANT SELECT (id, ho_ten, email, phong) ON nhanvien TO r_doc_MSSV;

-- Muc 2: ke thua muc 1
CREATE ROLE r_ketoan_MSSV;
GRANT r_doc_MSSV TO r_ketoan_MSSV;
GRANT INSERT, UPDATE ON hoadon TO r_ketoan_MSSV;
-- Cot SERIAL can quyen tren SEQUENCE, thieu la INSERT bao loi.
-- USAGE la DU cho nextval(). SELECT chi can cho currval() nen KHONG cap
-- -- giu dung nguyen tac dac quyen toi thieu.
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO r_ketoan_MSSV;

-- Muc 3: ke thua muc 2
CREATE ROLE r_truongphong_MSSV;
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
CREATE ROLE an_MSSV    LOGIN PASSWORD 'MatKhau_An_MSSV!';
CREATE ROLE binh_MSSV  LOGIN PASSWORD 'MatKhau_Binh_MSSV!';
CREATE ROLE cuong_MSSV LOGIN PASSWORD 'MatKhau_Cuong_MSSV!';

GRANT r_doc_MSSV         TO an_MSSV;
GRANT r_ketoan_MSSV      TO binh_MSSV;
GRANT r_truongphong_MSSV TO cuong_MSSV;

-- Khac MySQL: KHONG can SET DEFAULT ROLE, vai tro co hieu luc ngay
-- (vi role mac dinh la INHERIT).

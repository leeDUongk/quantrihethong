-- Bai lab 6 muc 5 -- RBAC tren MySQL
-- Chay bang:
--   docker compose exec -T mysql-db mysql -uroot -p < sql/02-mysql-rbac.sql

-- ============ 1. VAI TRO -- mo ta CONG VIEC, chua noi toi ai lam ============
CREATE ROLE IF NOT EXISTS 'r_doc_MSSV', 'r_ketoan_MSSV', 'r_truongphong_MSSV';

-- Muc 1: ai cung doc duoc cac bang nghiep vu
GRANT SELECT ON app_MSSV.hoadon TO 'r_doc_MSSV';
-- QUYEN MUC COT: xem duoc nhan vien nhung KHONG xem duoc cot luong
GRANT SELECT (id, ho_ten, email, phong) ON app_MSSV.nhanvien TO 'r_doc_MSSV';

-- Muc 2: KE THUA muc 1, them quyen ghi hoa don  (RBAC1 -- phan cap vai tro)
GRANT 'r_doc_MSSV' TO 'r_ketoan_MSSV';
GRANT INSERT, UPDATE ON app_MSSV.hoadon TO 'r_ketoan_MSSV';

-- Muc 3: KE THUA muc 2, them xoa va xem luong
GRANT 'r_ketoan_MSSV' TO 'r_truongphong_MSSV';
GRANT DELETE ON app_MSSV.hoadon   TO 'r_truongphong_MSSV';
GRANT SELECT ON app_MSSV.nhanvien TO 'r_truongphong_MSSV';

-- ============ 2. NGUOI DUNG ============
CREATE USER IF NOT EXISTS 'an_MSSV'@'%'    IDENTIFIED BY 'MatKhau_An_MSSV!';
CREATE USER IF NOT EXISTS 'binh_MSSV'@'%'  IDENTIFIED BY 'MatKhau_Binh_MSSV!';
CREATE USER IF NOT EXISTS 'cuong_MSSV'@'%' IDENTIFIED BY 'MatKhau_Cuong_MSSV!';

-- Gan VAI TRO, khong gan quyen le
GRANT 'r_doc_MSSV'         TO 'an_MSSV'@'%';
GRANT 'r_ketoan_MSSV'      TO 'binh_MSSV'@'%';
GRANT 'r_truongphong_MSSV' TO 'cuong_MSSV'@'%';

-- ============ 3. BAY SO MOT: phai KICH HOAT vai tro ============
-- Thieu dong nay thi dang nhap duoc nhung KHONG CO QUYEN GI.
SET DEFAULT ROLE ALL TO 'an_MSSV'@'%', 'binh_MSSV'@'%', 'cuong_MSSV'@'%';
FLUSH PRIVILEGES;

-- ============ 4. Kiem chung ============
SHOW GRANTS FOR 'binh_MSSV'@'%';
SHOW GRANTS FOR 'binh_MSSV'@'%' USING 'r_ketoan_MSSV';

-- Bai lab 6 muc 9.2 -- Ra soat quyen tren MySQL
-- Chay dinh ky moi quy:
--   docker compose exec -T mysql-db mysql -uroot -p < ra-soat/mysql-ra-soat.sql

SELECT '=== 1. Danh sach tai khoan ===' AS bao_cao;
SELECT user, host, plugin, password_last_changed, account_locked
  FROM mysql.user
  WHERE user NOT IN ('mysql.sys','mysql.session','mysql.infoschema')
  ORDER BY password_last_changed;
-- TIM: tai khoan doi mat khau tu rat lau, khong ai nhan la cua minh
--      -> dau hieu TAI KHOAN MA

SELECT '=== 2. Ai giu vai tro nao ===' AS bao_cao;
SELECT from_user AS vai_tro, to_user AS nguoi_dung
  FROM mysql.role_edges
  ORDER BY to_user, from_user;
-- TIM: mot nguoi xuat hien o nhieu vai tro thuoc nhieu phong ban
--      -> dau hieu QUYEN CONG DON

SELECT '=== 3. Tai khoan co quyen he thong manh ===' AS bao_cao;
SELECT grantee, privilege_type
  FROM information_schema.user_privileges
  WHERE privilege_type IN ('SUPER','FILE','PROCESS','SHUTDOWN','CREATE USER')
  ORDER BY grantee;
-- TIM: so luong phai RAT IT. Nhieu la vi pham dac quyen toi thieu.

SELECT '=== 4. Tai khoan cho phep ket noi tu bat ky dau ===' AS bao_cao;
SELECT user, host FROM mysql.user WHERE host = '%' ORDER BY user;
-- TIM: tai khoan ung dung nen gioi han host, khong de '%'

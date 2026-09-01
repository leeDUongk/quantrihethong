-- Bai lab 6 muc 9.2 -- Ra soat quyen tren PostgreSQL
--   docker compose exec -T postgres-db psql -U postgres -d app_MSSV < ra-soat/pg-ra-soat.sql

\echo '=== 1. Danh sach role va thuoc tinh ==='
SELECT rolname, rolsuper, rolcreaterole, rolcreatedb, rolcanlogin, rolvaliduntil
  FROM pg_roles
  WHERE rolname NOT LIKE 'pg\_%'
  ORDER BY rolsuper DESC, rolname;
-- TIM: so role co rolsuper = true phai RAT IT

\echo '=== 2. Ai la thanh vien cua vai tro nao ==='
SELECT m.rolname AS vai_tro, r.rolname AS thanh_vien
  FROM pg_auth_members am
  JOIN pg_roles r ON r.oid = am.member
  JOIN pg_roles m ON m.oid = am.roleid
  ORDER BY 1, 2;
-- TIM: mot nguoi thuoc nhieu vai tro nghiep vu khac nhau -> QUYEN CONG DON

\echo '=== 3. Vai tro nao co quyen gi tren bang nao ==='
SELECT grantee, table_name, string_agg(privilege_type, ', ' ORDER BY privilege_type) AS quyen
  FROM information_schema.role_table_grants
  WHERE grantee LIKE 'r\_%'
  GROUP BY grantee, table_name
  ORDER BY grantee, table_name;

\echo '=== 3b. QUYEN MUC COT -- muc de bi bo sot nhat ==='
-- Muc 3 o tren doc information_schema.role_table_grants, chi thay quyen o
-- MUC BANG. Mot vai tro chi duoc cap vai cot se KHONG hien o do -- va nguoi
-- doc bao cao se ket luan nham rang no khong co quyen gi.
-- Nguoc lai, neu mot vai tro le ra chi duoc vai cot ma o day hien DU CA COT,
-- thi quyen da bi noi rong luc nao do -- dung dau hieu can tim.
SELECT grantee, table_name, column_name, privilege_type
  FROM information_schema.role_column_grants
 WHERE grantee LIKE 'r\_%'
 ORDER BY grantee, table_name, column_name;

\echo '=== 3c. Doi chieu: quyen o MUC BANG lay thang tu ACL ==='
-- Chuoi ACL dang: nguoi_nhan=quyen/nguoi_cap.  r = SELECT, a = INSERT,
-- w = UPDATE, d = DELETE, D = TRUNCATE, x = REFERENCES, t = TRIGGER.
-- Neu thay r_doc_MSSV=r/postgres tren bang nhanvien thi vai tro do co
-- SELECT TOAN BANG -- ke ca cot luong.
SELECT relname AS bang, relacl AS danh_sach_quyen
  FROM pg_class
 WHERE relnamespace = 'public'::regnamespace AND relkind = 'r'
 ORDER BY relname;

\echo '=== 3d. Quyen mac dinh dang cho san ap len bang TAO MOI ==='
-- Day la quy tac tu thi hanh: moi bang do role ghi trong cot chu_tao tao ra
-- deu duoc cap quyen nay, ke ca bang do pg_restore tao lai.
SELECT defaclrole::regrole AS chu_tao,
       defaclobjtype       AS loai,
       defaclacl           AS quyen_mac_dinh
  FROM pg_default_acl;

\echo '=== 4. Bang nao da bat Row Level Security ==='
SELECT schemaname, tablename, rowsecurity
  FROM pg_tables
  WHERE schemaname = 'public'
  ORDER BY rowsecurity DESC, tablename;

\echo '=== 5. Cac chinh sach RLS dang co ==='
SELECT schemaname, tablename, policyname, cmd, qual
  FROM pg_policies
  WHERE schemaname = 'public';

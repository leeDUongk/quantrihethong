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

\echo '=== 4. Bang nao da bat Row Level Security ==='
SELECT schemaname, tablename, rowsecurity
  FROM pg_tables
  WHERE schemaname = 'public'
  ORDER BY rowsecurity DESC, tablename;

\echo '=== 5. Cac chinh sach RLS dang co ==='
SELECT schemaname, tablename, policyname, cmd, qual
  FROM pg_policies
  WHERE schemaname = 'public';

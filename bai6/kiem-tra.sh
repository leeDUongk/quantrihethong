#!/usr/bin/env bash
# Bai lab 6 -- kiem chung toan bo cai dat.
#   ./kiem-tra.sh k23
set -u
MSSV="${1:-k23}"
cd "$(dirname "$0")"
set -a; source .env 2>/dev/null; set +a
APP_DB="${APP_DB:-app_$MSSV}"

echo "=== 1. Bon container phai deu healthy / running ==="
docker compose ps

echo
echo "=== 2. Hai mang tach bach ==="
printf "  phpmyadmin -> mysql-db : "
docker exec phpmyadmin getent hosts mysql-db >/dev/null 2>&1 && echo "goi duoc (DUNG)" || echo "KHONG goi duoc (SAI)"
printf "  mysql-db   -> Internet : "
docker exec mysql-db timeout 5 bash -c "cat < /dev/null > /dev/tcp/8.8.8.8/53" 2>/dev/null \
  && echo "RA DUOC INTERNET (SAI -- kiem tra internal:true)" || echo "khong ra duoc (DUNG)"

echo
echo "=== 3. Vai tro va tai khoan tren MySQL ==="
docker compose exec -T mysql-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -t <<SQL 2>/dev/null
SELECT from_user AS vai_tro, to_user AS nguoi_dung FROM mysql.role_edges ORDER BY to_user;
SQL

echo "=== 4. Vai tro va tai khoan tren PostgreSQL ==="
docker compose exec -T postgres-db psql -U postgres -d "$APP_DB" -c "
SELECT m.rolname AS vai_tro, r.rolname AS thanh_vien
  FROM pg_auth_members am
  JOIN pg_roles r ON r.oid = am.member
  JOIN pg_roles m ON m.oid = am.roleid
  WHERE m.rolname LIKE 'r\\_%' ORDER BY 1,2;"

echo "=== 5. Thu quyen: an_$MSSV chi duoc DOC ==="
printf "  SELECT hoadon      : "
docker compose exec -T mysql-db mysql -u "an_$MSSV" -p"MatKhau_An_$MSSV!" "$APP_DB" \
  -e "SELECT COUNT(*) FROM hoadon;" >/dev/null 2>&1 && echo "duoc (DUNG)" || echo "KHONG duoc (SAI)"
printf "  DELETE hoadon      : "
docker compose exec -T mysql-db mysql -u "an_$MSSV" -p"MatKhau_An_$MSSV!" "$APP_DB" \
  -e "DELETE FROM hoadon WHERE id=999;" >/dev/null 2>&1 && echo "DUOC (SAI -- phai bi chan)" || echo "bi chan (DUNG)"
printf "  SELECT * nhanvien  : "
docker compose exec -T mysql-db mysql -u "an_$MSSV" -p"MatKhau_An_$MSSV!" "$APP_DB" \
  -e "SELECT * FROM nhanvien;" >/dev/null 2>&1 && echo "DUOC (SAI -- cot luong phai bi chan)" || echo "bi chan (DUNG)"

echo
echo "=== 6. Row Level Security ==="
docker compose exec -T postgres-db psql -U postgres -d "$APP_DB" -c "
SELECT tablename, rowsecurity FROM pg_tables
 WHERE schemaname='public' AND tablename='khachhang';"

echo "--- Chinh sach dang co ---"
docker compose exec -T postgres-db psql -U postgres -d "$APP_DB" -c "
SELECT policyname, cmd, qual FROM pg_policies WHERE tablename='khachhang';"

echo "--- Hai nguoi dung PHAI thay hai tap dong khac nhau ---"
for u in an binh; do
  printf "  %-6s thay %s dong: " "$u" ""
  docker compose exec -T -e PGPASSWORD="MatKhau_$(echo ${u^})_$MSSV!" postgres-db \
    psql -h postgres-db -U "${u}_$MSSV" -d "$APP_DB" -t -A \
    -c "SELECT COUNT(*) FROM khachhang;" 2>/dev/null || echo "khong ket noi duoc"
done

echo "--- Bien phien KHONG duoc phep vuot qua chinh sach ---"
printf "  an_%s sau khi SET app.chi_nhanh='HCM': " "$MSSV"
docker compose exec -T -e PGPASSWORD="MatKhau_An_$MSSV!" postgres-db \
  psql -h postgres-db -U "an_$MSSV" -d "$APP_DB" -t -A \
  -c "SET app.chi_nhanh='HCM'; SELECT COUNT(*) FROM khachhang;" 2>/dev/null | tail -1
echo "  (con so nay phai GIU NGUYEN nhu tren -- neu doi la chinh sach con lo hong)"

echo "--- Nguoi dung KHONG duoc doc bang anh xa ---"
printf "  an_%s doc nv_chi_nhanh: " "$MSSV"
docker compose exec -T -e PGPASSWORD="MatKhau_An_$MSSV!" postgres-db \
  psql -h postgres-db -U "an_$MSSV" -d "$APP_DB" -t -A \
  -c "SELECT COUNT(*) FROM nv_chi_nhanh;" >/dev/null 2>&1 \
  && echo "DOC DUOC (SAI)" || echo "bi chan (DUNG)"

echo "Xong. Doc ky cac dong (SAI) neu co."

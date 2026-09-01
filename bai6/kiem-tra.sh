#!/usr/bin/env bash
# Bai lab 6 -- kiem chung toan bo cai dat.
#   ./kiem-tra.sh k23
set -u
MSSV="${1:-k23}"
cd "$(dirname "$0")"
sed -i 's/\r$//' .env 2>/dev/null || true

# Doc .env neu co; neu khong thi suy ra tu MSSV theo dung cong thuc ma
# cai-dat.sh dung -- de kiem-tra.sh van chay duoc khi thieu .env.
if [ -f .env ]; then set -a; . ./.env; set +a; fi
APP_DB="${APP_DB:-app_$MSSV}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-RootMySQL_${MSSV}_2026}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-RootPg_${MSSV}_2026}"

# Khong dang nhap duoc bang tai khoan quan tri thi moi muc sau deu bao SAI
# ma khong phai vi phan quyen. Kiem tra truoc va noi ro.
if ! docker compose exec -T -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql-db \
     mysql -uroot -e "SELECT 1;" >/dev/null 2>&1; then
  echo "!! KHONG dang nhap duoc MySQL bang root voi mat khau trong .env."
  echo "!! Cac muc 3 va 5 duoi day se trong -- KHONG phai loi phan quyen."
  echo "!! Sua bang:  ./cai-dat.sh $MSSV"
  echo
fi

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
docker compose exec -T -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql-db mysql -uroot -t \
  -e "SELECT from_user AS vai_tro, to_user AS nguoi_dung
        FROM mysql.role_edges ORDER BY to_user;" 2>&1 | grep -v "^mysql: \[Warning\]" \
  || echo "  (khong doc duoc -- xem canh bao dang nhap o tren)"

echo "=== 4. Vai tro va tai khoan tren PostgreSQL ==="
echo "  (neu bang duoi day 0 rows thi sql/04-postgres-rbac.sql chua chay)"
docker compose exec -T postgres-db psql -U postgres -d "$APP_DB" -c "
SELECT m.rolname AS vai_tro, r.rolname AS thanh_vien
  FROM pg_auth_members am
  JOIN pg_roles r ON r.oid = am.member
  JOIN pg_roles m ON m.oid = am.roleid
  WHERE m.rolname LIKE 'r\\_%' ORDER BY 1,2;"

echo "=== 5. Thu quyen: an_$MSSV chi duoc DOC ==="
printf "  SELECT hoadon      : "
docker compose exec -T -e MYSQL_PWD="MatKhau_An_$MSSV!" mysql-db mysql -u "an_$MSSV" "$APP_DB" \
  -e "SELECT COUNT(*) FROM hoadon;" >/dev/null 2>&1 && echo "duoc (DUNG)" || echo "KHONG duoc (SAI)"
printf "  DELETE hoadon      : "
docker compose exec -T -e MYSQL_PWD="MatKhau_An_$MSSV!" mysql-db mysql -u "an_$MSSV" "$APP_DB" \
  -e "DELETE FROM hoadon WHERE id=999;" >/dev/null 2>&1 && echo "DUOC (SAI -- phai bi chan)" || echo "bi chan (DUNG)"
printf "  SELECT * nhanvien  : "
docker compose exec -T -e MYSQL_PWD="MatKhau_An_$MSSV!" mysql-db mysql -u "an_$MSSV" "$APP_DB" \
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
echo "    (an_$MSSV thuoc chi nhanh HN -> 3 dong; binh_$MSSV thuoc HCM -> 2 dong)"
for u in an binh; do
  printf "  %-6s thay: " "$u"
  n=$(docker compose exec -T -e PGPASSWORD="MatKhau_$(echo ${u^})_$MSSV!" postgres-db \
      psql -h postgres-db -U "${u}_$MSSV" -d "$APP_DB" -t -A \
      -c "SELECT COUNT(*) FROM khachhang;" 2>/dev/null | tr -d "[:space:]")
  case "$u:$n" in
    an:3|binh:2) echo "$n dong (DUNG)" ;;
    *:0)  echo "0 dong (SAI -- ham chi_nhanh_cua_toi() tra ve NULL?)" ;;
    *:)   echo "khong ket noi duoc (SAI)" ;;
    *)    echo "$n dong (SAI)" ;;
  esac
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

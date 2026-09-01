#!/usr/bin/env bash
# =====================================================================
# Bai lab 6 -- CAI DAT SACH, doc lap hoan toan voi cac bai lab truoc.
#
#   ./cai-dat.sh k23          # cai sach: xoa stack bai 6 cu roi dung lai
#   ./cai-dat.sh k23 --giu    # giu nguyen du lieu dang co, chi nap lai RBAC
#
# Chay bao nhieu lan cung ra dung mot ket qua. Khong can chay don-dep.sh
# truoc, khong dung lai bat cu thu gi cua bai lab 2, 3, 4, 5.
# =====================================================================
set -euo pipefail

MSSV="${1:?Cach dung: ./cai-dat.sh <MSSV>   (vi du: ./cai-dat.sh k23)}"
case "$MSSV" in --*) echo "LOI: tham so dau tien phai la MSSV, khong phai co."; exit 1;; esac
GIU=0
for t in "$@"; do [ "$t" = "--giu" ] && GIU=1; done
cd "$(dirname "$0")"

echo "=================================================================="
echo " BAI LAB 6 -- CAI DAT   (MSSV = $MSSV)"
echo "=================================================================="

# ---------------------------------------------------------------------
# 1. Chuan hoa xuong dong
# File di qua Windows co the mang ky tu CR o cuoi dong. Bash doc CR nhu
# mot phan cua gia tri, Docker Compose thi cat bo -- hai ben lech nhau
# mot ky tu vo hinh la du gay "Access denied". Cat sach ngay tu dau.
# ---------------------------------------------------------------------
find . -type f \( -name '*.sh' -o -name '*.sql' -o -name '*.yml' \
     -o -name '*.example' -o -name '.env' \) -print0 \
  | xargs -0 -r sed -i 's/\r$//'
chmod +x ./*.sh backup/*.sh 2>/dev/null || true

# ---------------------------------------------------------------------
# 2. Khoi phuc file SQL ve ban goc roi moi thay MSSV
# Nho co ban goc trong .mau/ nen chay lai voi MSSV khac van dung.
# ---------------------------------------------------------------------
if [ ! -d .mau ]; then
  mkdir -p .mau/sql .mau/ra-soat
  cp -f sql/*.sql     .mau/sql/
  cp -f ra-soat/*.sql .mau/ra-soat/
  echo "==> Da luu ban goc cac file SQL vao .mau/"
else
  cp -f .mau/sql/*.sql     sql/
  cp -f .mau/ra-soat/*.sql ra-soat/
  echo "==> Da khoi phuc cac file SQL ve ban goc"
fi
sed -i "s/MSSV/$MSSV/g" sql/*.sql ra-soat/*.sql
echo "==> Da thay MSSV = $MSSV trong sql/ va ra-soat/"

# ---------------------------------------------------------------------
# 3. Mat khau -- chi ton tai o DUNG MOT CHO
# Cac bien duoi day la nguon duy nhat. Tu chung ghi ra .env cho Docker
# Compose, va cung chinh chung duoc truyen thang cho lenh mysql / psql.
# Script KHONG "source .env", nen khong the co chuyen Compose va Bash
# doc ra hai chuoi khac nhau.
# ---------------------------------------------------------------------
export APP_DB="app_$MSSV"
export MYSQL_ROOT_PASSWORD="RootMySQL_${MSSV}_2026"
export POSTGRES_PASSWORD="RootPg_${MSSV}_2026"
export PGADMIN_EMAIL="admin@${MSSV}.lab"
export PGADMIN_PASSWORD="PgAdmin_${MSSV}_2026"

if [ "$GIU" -eq 1 ] && [ -f .env ]; then
  echo "==> --giu: dung lai .env dang co"
  set -a; . ./.env; set +a
else
  printf '%s\n' \
    "# File nay do cai-dat.sh sinh ra. Sua tay se bi ghi de o lan chay sau." \
    "APP_DB=$APP_DB" \
    "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
    "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" \
    "PGADMIN_EMAIL=$PGADMIN_EMAIL" \
    "PGADMIN_PASSWORD=$PGADMIN_PASSWORD" > .env
  echo "==> Da sinh .env"
fi

# ---------------------------------------------------------------------
# 4. Don rieng bai lab 6 (khong dung toi bai lab khac)
# ---------------------------------------------------------------------
if [ "$GIU" -eq 0 ]; then
  echo "==> Xoa stack bai lab 6 cu (neu co) -- KHONG dung toi bai lab khac"
  docker compose down -v --remove-orphans >/dev/null 2>&1 || true
  for c in mysql-db postgres-db phpmyadmin pgadmin; do
    docker rm -f "$c" >/dev/null 2>&1 && echo "    - da xoa container con sot: $c" || true
  done
fi

for cong in 8080 8081; do
  ai=$(docker ps --format '{{.Names}} {{.Ports}}' 2>/dev/null | grep ":$cong->" | awk '{print $1}' || true)
  if [ -n "$ai" ]; then
    echo "LOI: cong $cong dang bi container \"$ai\" chiem."
    echo "     Dung no roi chay lai:  docker rm -f $ai"
    exit 1
  fi
done

# ---------------------------------------------------------------------
# 5. Dung stack
# ---------------------------------------------------------------------
echo "==> Dung stack (lan dau se tai image, mat vai phut)"
docker compose up -d

# ---------------------------------------------------------------------
# 6. Cho toi khi DANG NHAP DUOC -- khong chi cho "healthy"
# "healthy" chua du: mysqladmin ping van bao song ngay ca khi sai mat
# khau. Phep thu dung la thu dang nhap that bang chinh mat khau se dung
# de nap SQL o buoc sau.
# ---------------------------------------------------------------------
thu_mysql() {
  docker compose exec -T -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql-db \
    mysql -uroot -e "SELECT 1;" </dev/null >/dev/null 2>&1
}
thu_pg() {
  docker compose exec -T -e PGPASSWORD="$POSTGRES_PASSWORD" postgres-db \
    psql -h 127.0.0.1 -U postgres -d "$APP_DB" -c "SELECT 1;" </dev/null >/dev/null 2>&1
}

echo "==> Cho hai CSDL nhan dang nhap (toi da 5 phut)"
ok_my=0; ok_pg=0
for i in $(seq 1 60); do
  [ "$ok_my" -eq 0 ] && thu_mysql && ok_my=1
  [ "$ok_pg" -eq 0 ] && thu_pg    && ok_pg=1
  printf "\r    MySQL: %-10s PostgreSQL: %-10s (%ds)" \
    "$([ $ok_my -eq 1 ] && echo 'dang nhap OK' || echo 'dang cho')" \
    "$([ $ok_pg -eq 1 ] && echo 'dang nhap OK' || echo 'dang cho')" "$((i*5))"
  [ "$ok_my" -eq 1 ] && [ "$ok_pg" -eq 1 ] && break
  sleep 5
done
echo

if [ "$ok_my" -eq 0 ] || [ "$ok_pg" -eq 0 ]; then
  echo
  echo "=================================================================="
  echo " KHONG DANG NHAP DUOC -- thong tin de chan doan"
  echo "=================================================================="
  echo "-- Mat khau script dang dung:"
  printf '   MYSQL_ROOT_PASSWORD = %q\n' "$MYSQL_ROOT_PASSWORD"
  printf '   POSTGRES_PASSWORD   = %q\n' "$POSTGRES_PASSWORD"
  echo "-- Mat khau ben trong container:"
  docker inspect mysql-db    -f '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null \
    | grep -E '^MYSQL_ROOT_PASSWORD=' | sed 's/^/   /' || echo "   (khong doc duoc)"
  docker inspect postgres-db -f '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null \
    | grep -E '^POSTGRES_PASSWORD='   | sed 's/^/   /' || echo "   (khong doc duoc)"
  echo "-- Nhat ky 15 dong cuoi:"
  docker compose logs --tail 15 mysql-db    2>/dev/null | sed 's/^/   /'
  docker compose logs --tail 15 postgres-db 2>/dev/null | sed 's/^/   /'
  echo
  echo " Hai chuoi tren PHAI giong het nhau. Neu khac, chay lai cho sach:"
  echo "     cd $(pwd) && docker compose down -v && ./cai-dat.sh $MSSV"
  echo "=================================================================="
  exit 1
fi

# ---------------------------------------------------------------------
# 7. Nap RBAC
# ---------------------------------------------------------------------
echo "==> Nap vai tro va tai khoan cho MySQL"
# MYSQL_PWD thay cho -p... de khong in canh bao "Using a password on the
# command line interface can be insecure" o moi lenh.
docker compose exec -T -e MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql-db \
  mysql -uroot < sql/02-mysql-rbac.sql

echo "==> Nap vai tro va tai khoan cho PostgreSQL"
docker compose exec -T postgres-db \
  psql -U postgres -d "$APP_DB" -v ON_ERROR_STOP=1 -q < sql/04-postgres-rbac.sql

echo "==> Bat Row Level Security"
docker compose exec -T postgres-db \
  psql -U postgres -d "$APP_DB" -v ON_ERROR_STOP=1 -q < sql/05-postgres-rls.sql

# ---------------------------------------------------------------------
# 8. Bao cao
# ---------------------------------------------------------------------
echo
echo "=================================================================="
echo " CAI DAT XONG"
echo "=================================================================="
docker compose ps
cat <<HD

 phpMyAdmin : http://<IP-may-ao>:8080   (root / $MYSQL_ROOT_PASSWORD)
 pgAdmin    : http://<IP-may-ao>:8081   ($PGADMIN_EMAIL / $PGADMIN_PASSWORD)

 Ba tai khoan de thu quyen (mat khau xem trong sql/02-mysql-rbac.sql):
   an_$MSSV     -- vai tro r_doc         : chi doc
   binh_$MSSV   -- vai tro r_ketoan      : doc + ghi hoa don
   cuong_$MSSV  -- vai tro r_truongphong : them xoa va xem luong

 Buoc tiep theo:
   ./kiem-tra.sh $MSSV        # kiem chung toan bo
HD

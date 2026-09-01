#!/usr/bin/env bash
# Bai lab 6 -- cai dat mot mach: dung stack, cho healthy, nap RBAC.
#
# Cach dung:
#   ./cai-dat.sh k23              # cai binh thuong
#   ./cai-dat.sh k23 --lam-lai    # XOA volume cu roi cai lai tu dau
set -euo pipefail

MSSV="${1:?Cach dung: ./cai-dat.sh <MSSV> [--lam-lai]   (vi du: ./cai-dat.sh k23)}"
LAM_LAI=0
for t in "$@"; do [ "$t" = "--lam-lai" ] && LAM_LAI=1; done
cd "$(dirname "$0")"

# ---------- 0. Chuan hoa xuong dong ----------
# File tai ve tu GitHub qua Windows co the mang ky tu CR o cuoi dong. Bash doc
# CR nhu mot phan cua mat khau, Docker Compose thi khong -- lech nhau la
# ERROR 1045. Cat bo CR truoc khi lam bat cu viec gi khac.
sed -i 's/\r$//' .env.example .env sql/*.sql ra-soat/*.sql 2>/dev/null || true

# ---------- 1. Chuan bi .env va thay MSSV (chi lam mot lan) ----------
if [ ! -f .da-thay-mssv ]; then
  [ -f .env ] || cp .env.example .env
  sed -i "s/MSSV/$MSSV/g" .env sql/*.sql ra-soat/*.sql
  date > .da-thay-mssv
  echo "==> Da thay MSSV = $MSSV trong .env, sql/ va ra-soat/"
else
  echo "==> Da thay MSSV tu truoc (xoa file .da-thay-mssv neu muon lam lai)"
fi
chmod +x backup/*.sh don-dep.sh kiem-tra.sh 2>/dev/null || true

set -a; source .env; set +a

# ---------- 1b. Volume cu tu lan chay truoc ----------
# MySQL va PostgreSQL CHI doc mat khau trong .env dung mot lan, luc thu muc du
# lieu con trong. Neu volume da ton tai tu truoc khi thay MSSV thi mat khau
# nam trong volume van la ban cu -> dang nhap that bai.
if [ "$LAM_LAI" -eq 1 ]; then
  echo "==> --lam-lai: xoa container va volume cu cua bai lab nay"
  docker compose down -v --remove-orphans 2>/dev/null || true
fi

# ---------- 2. Dung stack ----------
echo "==> Dung stack (lan dau se tai image, mat vai phut)"
docker compose up -d

# ---------- 3. Cho ca hai DBMS san sang ----------
echo "==> Cho MySQL va PostgreSQL bao healthy"
ms=""; ps=""
for i in $(seq 1 60); do
  ms=$(docker inspect -f '{{.State.Health.Status}}' mysql-db    2>/dev/null || echo "chua")
  ps=$(docker inspect -f '{{.State.Health.Status}}' postgres-db 2>/dev/null || echo "chua")
  printf "\r    mysql-db: %-10s postgres-db: %-10s (%ds)" "$ms" "$ps" "$((i*5))"
  [ "$ms" = "healthy" ] && [ "$ps" = "healthy" ] && break
  sleep 5
done
echo
if [ "$ms" != "healthy" ] || [ "$ps" != "healthy" ]; then
  echo "LOI: qua 5 phut ma chua healthy. Xem log:"
  echo "  docker compose logs mysql-db"
  echo "  docker compose logs postgres-db"
  exit 1
fi

# ---------- 3b. Thu dang nhap quan tri TRUOC khi nap SQL ----------
# Buoc nay bat loi mat khau lech ngay tai cho, kem huong dan sua -- thay vi de
# script chet giua chung voi mot dong ERROR 1045 kho hieu.
loi_mat_khau() {
  cat <<HD

==================================================================
 KHONG DANG NHAP DUOC VAO $1 BANG MAT KHAU TRONG .env
==================================================================
 Hai nguyen nhan thuong gap:

 1. Volume du lieu da duoc tao TU LAN CHAY TRUOC, khi .env con mang
    mat khau khac (vi du chua thay MSSV). He quan tri CSDL chi doc
    mat khau mot lan duy nhat luc khoi tao thu muc du lieu, nen mat
    khau nam trong volume van la ban cu.

 2. File .env tai ve tu Windows con ky tu CR o cuoi dong.

 Cach sua (se XOA du lieu trong hai CSDL cua bai lab nay, dung y do
 vi ta dang cai lai tu dau):

     cd $(pwd) && ./cai-dat.sh $MSSV --lam-lai

==================================================================
HD
  exit 1
}

echo "==> Thu dang nhap quan tri"
printf "    MySQL root      : "
if docker compose exec -T mysql-db \
     mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
  echo "OK"
else
  echo "THAT BAI"; loi_mat_khau "MySQL"
fi

printf "    PostgreSQL admin: "
if docker compose exec -T -e PGPASSWORD="$POSTGRES_PASSWORD" postgres-db \
     psql -h postgres-db -U postgres -d "$APP_DB" -c "SELECT 1;" >/dev/null 2>&1; then
  echo "OK"
else
  echo "THAT BAI"; loi_mat_khau "PostgreSQL"
fi

# ---------- 4. Nap RBAC ----------
echo "==> Nap vai tro va tai khoan cho MySQL"
docker compose exec -T mysql-db \
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" < sql/02-mysql-rbac.sql

echo "==> Nap vai tro va tai khoan cho PostgreSQL"
docker compose exec -T postgres-db \
  psql -U postgres -d "$APP_DB" -v ON_ERROR_STOP=1 < sql/04-postgres-rbac.sql

echo "==> Bat Row Level Security"
docker compose exec -T postgres-db \
  psql -U postgres -d "$APP_DB" -v ON_ERROR_STOP=1 < sql/05-postgres-rls.sql

# ---------- 5. Bao cao ----------
echo
echo "=================================================================="
echo " CAI DAT XONG"
echo "=================================================================="
docker compose ps
cat <<HD

 phpMyAdmin : http://<IP-may-ao>:8080   (root / mat khau trong .env)
 pgAdmin    : http://<IP-may-ao>:8081   ($PGADMIN_EMAIL)

 Ba tai khoan de thu quyen (mat khau xem trong sql/02-mysql-rbac.sql):
   an_$MSSV     -- vai tro r_doc         : chi doc
   binh_$MSSV   -- vai tro r_ketoan      : doc + ghi hoa don
   cuong_$MSSV  -- vai tro r_truongphong : them xoa va xem luong

 Buoc tiep theo:
   ./kiem-tra.sh $MSSV        # kiem chung toan bo
   docker compose exec mysql-db mysql -u an_$MSSV -p $APP_DB
HD

#!/usr/bin/env bash
# Bai lab 6 -- cai dat mot mach: dung stack, cho healthy, nap RBAC.
#
# Cach dung:   ./cai-dat.sh k23
set -euo pipefail

MSSV="${1:?Cach dung: ./cai-dat.sh <MSSV>   (vi du: ./cai-dat.sh k23)}"
cd "$(dirname "$0")"

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

# ---------- 2. Dung stack ----------
echo "==> Dung stack (lan dau se tai image, mat vai phut)"
docker compose up -d

# ---------- 3. Cho ca hai DBMS san sang ----------
echo "==> Cho MySQL va PostgreSQL bao healthy"
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

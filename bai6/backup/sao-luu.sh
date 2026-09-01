#!/usr/bin/env bash
# Bai lab 6 muc 8.1 -- sao luu ca hai CSDL
# Chay tu thu muc goc cua bai lab:   ./backup/sao-luu.sh
set -euo pipefail

GOC="$(cd "$(dirname "$0")/.." && pwd)"
cd "$GOC"
# shellcheck disable=SC1091
source .env

NGAY=$(date +%F-%H%M)
mkdir -p backup

echo "==> Sao luu MySQL"
# --single-transaction: chup anh nhat quan MA KHONG KHOA BANG
# --routines --triggers: thieu la thu tuc va trigger KHONG co trong ban sao luu
# -T cua docker compose exec: thieu la file bi lan ky tu dieu khien -> HONG
docker compose exec -T mysql-db \
  mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" \
  --single-transaction --routines --triggers "$APP_DB" \
  > "backup/mysql-$APP_DB-$NGAY.sql"

echo "==> Sao luu PostgreSQL"
# -Fc: dinh dang nen, cho phep pg_restore khoi phuc CHON LOC tung bang
docker compose exec -T postgres-db \
  pg_dump -U postgres -Fc "$APP_DB" \
  > "backup/pg-$APP_DB-$NGAY.dump"

echo "==> Ket qua"
ls -lh backup/mysql-*.sql backup/pg-*.dump | tail -4

echo "==> Giu 7 ban gan nhat"
ls -t backup/mysql-*.sql 2>/dev/null | tail -n +8 | xargs -r rm --
ls -t backup/pg-*.dump   2>/dev/null | tail -n +8 | xargs -r rm --

echo "Xong. LUU Y: ban sao luu nam cung may ao voi CSDL thi CHUA phai la sao luu."

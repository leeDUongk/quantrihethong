#!/usr/bin/env bash
# Bai lab 6 muc 8.2 -- khoi phuc va CHUNG MINH da khoi phuc duoc
# Cach dung:   ./backup/khoi-phuc.sh backup/mysql-app_MSSV-2026-08-23-1400.sql
set -euo pipefail

GOC="$(cd "$(dirname "$0")/.." && pwd)"
cd "$GOC"
# shellcheck disable=SC1091
source .env

FILE="${1:?Cach dung: ./backup/khoi-phuc.sh <duong-dan-file-sao-luu>}"

dem_mysql() {
  docker compose exec -T mysql-db \
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -N -B \
    -e "SELECT COUNT(*) FROM $APP_DB.hoadon;" 2>/dev/null
}

case "$FILE" in
  *.sql)
    echo "==> So dong hoa don TRUOC khi khoi phuc: $(dem_mysql)"
    echo "==> Dang khoi phuc MySQL tu $FILE"
    docker compose exec -T mysql-db \
      mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$APP_DB" < "$FILE"
    echo "==> So dong hoa don SAU khi khoi phuc: $(dem_mysql)"
    ;;
  *.dump)
    echo "==> Dang khoi phuc PostgreSQL tu $FILE"
    # --clean --if-exists: xoa doi tuong cu truoc khi tao lai.
    # Thieu la bao loi trung khoa chinh va DUNG GIUA CHUNG.
    docker compose exec -T postgres-db \
      pg_restore -U postgres -d "$APP_DB" --clean --if-exists < "$FILE"
    docker compose exec -T postgres-db \
      psql -U postgres -d "$APP_DB" -c "SELECT COUNT(*) AS so_hoa_don FROM hoadon;"
    ;;
  *)
    echo "Khong nhan ra dinh dang. Can file .sql (MySQL) hoac .dump (PostgreSQL)."
    exit 1
    ;;
esac

echo "Xong. Chup lai ba con so truoc - sau khi xoa - sau khi khoi phuc de nop bai."

#!/usr/bin/env bash
# Bai lab 6 -- BUOC 0: don sach may ao truoc khi cai dat.
#
# Cach dung:
#   ./don-dep.sh            -> don rieng cac bai lab (an toan hon)
#   ./don-dep.sh --tat-ca   -> don SACH toan bo Docker tren may ao
#   Them --dong-y de bo qua buoc hoi xac nhan.
set -u

TAT_CA=0
DONG_Y=0
for t in "$@"; do
  [ "$t" = "--tat-ca" ] && TAT_CA=1
  [ "$t" = "--dong-y" ] && DONG_Y=1
done

echo "=================================================================="
if [ "$TAT_CA" -eq 1 ]; then
  echo " CANH BAO: se xoa TOAN BO container, image, volume, network"
  echo " cua Docker tren may ao nay -- ke ca thu khong thuoc bai lab."
else
  echo " Se dung va xoa container + volume cua cac bai lab 2, 3, 5, 6."
  echo " DU LIEU TRONG CAC BAI LAB DO SE MAT."
fi
echo " Khong the hoan tac."
echo "=================================================================="

if [ "$DONG_Y" -ne 1 ]; then
  read -r -p "Go dung chu  DONG Y  roi Enter de tiep tuc: " tra_loi
  if [ "$tra_loi" != "DONG Y" ]; then echo "Da huy, khong xoa gi."; exit 1; fi
fi

echo
echo "==> 1. Dung cac stack Compose cua bai lab truoc (neu con thu muc)"
for d in ~/bai3/php-web-app ~/bai3/wordpress-lab ~/npm-lab/proxy \
         ~/npm-lab/static-site ~/npm-lab/backend ~/db-lab ~/php-web-app; do
  if [ -f "$d/docker-compose.yml" ]; then
    echo "    - $d"
    (cd "$d" && docker compose down -v --remove-orphans 2>/dev/null) || true
  fi
done

if [ "$TAT_CA" -eq 1 ]; then
  echo "==> 2. Xoa toan bo container"
  docker ps -aq | xargs -r docker rm -f
  echo "==> 3. Xoa toan bo volume, network, image khong dung"
  docker system prune -af --volumes
else
  echo "==> 2. Xoa cac container con sot cua bai lab"
  for c in mysql-db postgres-db phpmyadmin pgadmin wp-mysql wp-app wp-phpmyadmin \
           wp-redis php-web redis-cache static-site nginx-proxy-manager \
           wordpress wp-db; do
    docker rm -f "$c" 2>/dev/null && echo "    - da xoa $c" || true
  done
  echo "==> 3. Xoa volume va network mo coi"
  docker volume prune -f >/dev/null
  docker network prune -f >/dev/null
fi

echo
echo "==> 4. Kiem tra ket qua"
echo "--- Container dang chay ---"
docker ps
echo "--- Cong 80 / 3306 / 5432 / 8080 / 8081 ---"
sudo ss -ltnp 2>/dev/null | grep -E ':80 |:3306 |:5432 |:8080 |:8081 ' || echo "  (khong cong nao dang bi chiem -- DUNG)"
echo
echo "Da don xong. Chay tiep:  ./cai-dat.sh <MSSV>"

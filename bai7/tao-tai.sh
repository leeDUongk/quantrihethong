#!/usr/bin/env bash
# =====================================================================
# Bai lab 7 -- SINH TAI GIA de chung minh bieu do phan anh he thong that
#
#   ./tao-tai.sh          # mac dinh 120 giay
#   ./tao-tai.sh 300      # 300 giay
#
# Tieu chi Moc 7 doi hoi: "tao tai gia va chi ra duoc dinh CPU tuong ung
# tren dashboard". Mot bieu do dep nhung khong nhuc nhich khi he thong
# that su ban thi chua chung minh duoc dieu gi.
# =====================================================================
set -u
GIAY="${1:-120}"
cd "$(dirname "$0")"

echo "=================================================================="
echo " SINH TAI GIA TRONG $GIAY GIAY"
echo "=================================================================="
echo " Bat dau : $(date '+%H:%M:%S')  <-- ghi lai gio nay"
echo

# Ep CPU trong container wordpress. Dung "yes > /dev/null" vi no chi
# ton CPU, khong ton RAM va khong ghi dia -- co lap dung mot bien so.
docker compose exec -d wordpress sh -c "timeout $GIAY sh -c 'while :; do :; done'" 2>/dev/null \
  || { echo "LOI: khong goi duoc container wordpress. Stack da chay chua?"; exit 1; }

# Dong thoi ban truy van vao MySQL de bieu do "truy van/giay" cung nhuc nhich.
docker compose exec -d mysql-db sh -c \
  "timeout $GIAY sh -c 'while :; do mysql -u\"\$MYSQL_USER\" -p\"\$MYSQL_PASSWORD\" \
   -e \"SELECT 1\" \"\$MYSQL_DATABASE\" >/dev/null 2>&1; done'" 2>/dev/null || true

for ((i=GIAY; i>0; i-=10)); do
  printf "\r Con lai : %3ds " "$i"
  sleep 10
done
echo
echo " Ket thuc: $(date '+%H:%M:%S')  <-- va ghi lai gio nay"
echo
cat <<'HD'
==================================================================
 VIEC PHAI LAM NGAY BAY GIO
==================================================================
 1. Mo Grafana, dat khung thoi gian "Last 15 minutes".
 2. Nhin bieu do "CPU tung container": duong cua "wordpress" phai
    NHO LEN thanh mot khoi vuong dung bang khoang thoi gian o tren.
 3. Nhin bieu do "So truy van moi giay": phai co mot dinh cung luc.
 4. Chup man hinh CA HAI bieu do, thay ro hai moc gio vua in ra.

 Neu duong bieu do KHONG nhuc nhich, dashboard cua ban dang ve du
 lieu gia hoac lay sai chi so -- xu ly truoc khi di tiep.
HD

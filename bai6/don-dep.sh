#!/usr/bin/env bash
# =====================================================================
# Bai lab 6 -- BUOC 0: dua Docker tren may ao ve trang thai TRONG.
#
#   ./don-dep.sh            # xoa moi container, volume, network (GIU image)
#   ./don-dep.sh --tat-ca   # xoa ca image -- lan sau phai tai lai tu dau
#   Them --dong-y de bo qua buoc hoi xac nhan.
#
# Bai lab 6 dung mot he thong hoan toan moi, khong dung lai gi cua bai
# lab 2, 3, 4, 5. Don sach truoc de khong con container nao giu cong
# 3306 / 5432 / 8080 / 8081 va khong con volume cu gay nham lan.
# =====================================================================
set -u

TAT_CA=0
DONG_Y=0
for t in "$@"; do
  [ "$t" = "--tat-ca" ] && TAT_CA=1
  [ "$t" = "--dong-y" ] && DONG_Y=1
done

echo "=================================================================="
echo " CANH BAO -- se xoa TOAN BO container, volume va network cua Docker"
echo " tren may ao nay, ke ca thu khong thuoc hoc phan."
if [ "$TAT_CA" -eq 1 ]; then
  echo " Che do --tat-ca: xoa CA IMAGE. Lan cai sau phai tai lai tu Internet."
else
  echo " Image duoc GIU lai de lan cai sau khong phai tai lai."
fi
echo
echo " DU LIEU CUA CAC BAI LAB TRUOC SE MAT VINH VIEN:"
echo "   - bai viet WordPress cua Bai lab 3"
echo "   - bang du lieu cua Bai lab 2"
echo "   - cau hinh Proxy Host va chung chi cua Bai lab 5"
echo " Con can thi sao luu truoc, hoac dung snapshot cua VMware."
echo " Khong the hoan tac."
echo "=================================================================="

if [ "$DONG_Y" -ne 1 ]; then
  read -r -p "Go dung chu  DONG Y  roi Enter de tiep tuc: " tra_loi
  if [ "$tra_loi" != "DONG Y" ]; then echo "Da huy, khong xoa gi."; exit 1; fi
fi

echo
echo "==> 1. Dung va xoa moi container"
ds=$(docker ps -aq 2>/dev/null)
if [ -n "$ds" ]; then
  echo "$ds" | xargs -r docker rm -f >/dev/null 2>&1
  echo "    da xoa $(echo "$ds" | wc -l) container"
else
  echo "    khong co container nao"
fi

echo "==> 2. Xoa moi volume"
vs=$(docker volume ls -q 2>/dev/null)
if [ -n "$vs" ]; then
  echo "$vs" | xargs -r docker volume rm -f >/dev/null 2>&1
  echo "    da xoa $(echo "$vs" | wc -l) volume"
else
  echo "    khong co volume nao"
fi

echo "==> 3. Xoa moi network tu tao (giu bridge / host / none cua he thong)"
docker network prune -f >/dev/null 2>&1
echo "    xong"

if [ "$TAT_CA" -eq 1 ]; then
  echo "==> 4. Xoa moi image"
  docker image prune -af >/dev/null 2>&1
  echo "    xong"
fi

echo
echo "==> Kiem tra ket qua"
echo "--- Container (phai trong) ---"
docker ps -a
echo "--- Volume (phai trong) ---"
docker volume ls
echo "--- Cong 3306 / 5432 / 8080 / 8081 do Docker giu ---"
if docker ps --format '{{.Names}} {{.Ports}}' 2>/dev/null | grep -qE ':(3306|5432|8080|8081)->'; then
  docker ps --format '{{.Names}} {{.Ports}}' | grep -E ':(3306|5432|8080|8081)->'
  echo "  ^ VAN CON container giu cong -- xem lai"
else
  echo "  khong con container nao giu cac cong nay -- DUNG"
fi

echo
echo "Docker da ve trang thai trong. Chay tiep:  ./cai-dat.sh <MSSV>"

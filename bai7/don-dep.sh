#!/usr/bin/env bash
# Bai lab 7 -- dua Docker ve trang thai trong.
#   ./don-dep.sh            # xoa container + volume + network, GIU image
#   ./don-dep.sh --tat-ca   # xoa ca image
#   ./don-dep.sh --dong-y   # bo qua buoc hoi xac nhan
set -u
cd "$(dirname "$0")"
TATCA=0; DONGY=0
for t in "$@"; do
  [ "$t" = "--tat-ca" ] && TATCA=1
  [ "$t" = "--dong-y" ] && DONGY=1
done

cat <<'HD'
==================================================================
 CANH BAO -- se xoa TOAN BO container, volume va network cua Docker
 tren may ao nay, ke ca thu khong thuoc hoc phan.
 Image duoc GIU lai de lan cai sau khong phai tai lai.
 Khong the hoan tac.
==================================================================
HD
if [ "$DONGY" -eq 0 ]; then
  printf "Go dung chu  DONG Y  roi Enter de tiep tuc: "
  read -r tl
  [ "$tl" = "DONG Y" ] || { echo "Da huy."; exit 1; }
fi

echo "==> 1. Dung va xoa moi container"
ids=$(docker ps -aq); n=0
[ -n "$ids" ] && { docker rm -f $ids >/dev/null 2>&1; n=$(echo "$ids" | wc -l); }
echo "    da xoa $n container"

echo "==> 2. Xoa moi volume"
vs=$(docker volume ls -q); n=0
[ -n "$vs" ] && { docker volume rm -f $vs >/dev/null 2>&1; n=$(echo "$vs" | wc -l); }
echo "    da xoa $n volume"

echo "==> 3. Xoa moi network tu tao"
docker network prune -f >/dev/null 2>&1
echo "    xong"

if [ "$TATCA" -eq 1 ]; then
  echo "==> 4. Xoa moi image"
  is=$(docker images -q); [ -n "$is" ] && docker rmi -f $is >/dev/null 2>&1
  echo "    xong"
fi

echo "==> Kiem tra ket qua"
echo "--- Container (phai trong) ---"; docker ps -a
echo "--- Volume (phai trong) ---";    docker volume ls
echo "--- Cong 8080 / 9090 / 3000 do Docker giu ---"
if docker ps --format '{{.Ports}}' | grep -qE ":8080->|:9090->|:3000->"; then
  docker ps --format '  {{.Names}} {{.Ports}}' | grep -E ":8080->|:9090->|:3000->"
else
  echo "  khong con container nao giu cac cong nay -- DUNG"
fi
echo "Docker da ve trang thai trong. Chay tiep:  ./cai-dat.sh <MSSV>"

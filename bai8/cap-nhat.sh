#!/usr/bin/env bash
# Bai lab 8 -- lay ban moi nhat tu GitHub.
#   ./cap-nhat.sh k23
# Khong dung stack dang chay, khong xoa du lieu.
set -euo pipefail
MSSV="${1:?Cach dung: ./cap-nhat.sh <MSSV>}"
cd "$(dirname "$0")"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "LOI: thu muc nay khong nam trong mot kho git."
  echo "     Co the ban da CHEP thu muc bai8 ra ngoai thay vi clone."
  exit 1
fi

# Kho duoc day len tu Windows, noi khong co bit thuc thi. Tren Linux,
# "chmod +x" lam git thay moi file .sh deu "da bi sua". Bao git bo qua.
git config core.fileMode false

echo "==> Tra monitoring/ ve ban goc"
git checkout -- monitoring 2>/dev/null || true

echo "==> Keo ban moi tu GitHub"
if ! git pull --ff-only; then
  echo
  echo "LOI: khong keo ve duoc. Hai nguyen nhan thuong gap:"
  echo "  1. May ao khong ra duoc Internet -- thu:  ping -c1 github.com"
  echo "  2. Ban da tu sua mot file khac. Xem:  git status --short"
  exit 1
fi

echo "==> Thay lai MSSV = $MSSV"
sed -i "s/MSSV/$MSSV/g" monitoring/prometheus.yml
chmod +x ./*.sh 2>/dev/null || true

cat <<HD

==================================================================
 DA CAP NHAT XONG -- stack van dang chay, du lieu con nguyen
==================================================================
 Nap lai cau hinh moi:
     ./cai-dat.sh $MSSV
 Roi kiem chung:
     ./kiem-tra.sh $MSSV
HD

#!/usr/bin/env bash
# =====================================================================
# Bai lab 6 -- LAY BAN MOI NHAT TU GITHUB
#
#   ./cap-nhat.sh k23
#
# Dung khi giang vien thong bao co ban sua. Script KHONG dung stack dang
# chay va KHONG xoa du lieu -- no chi cap nhat file nguon.
# =====================================================================
set -euo pipefail

MSSV="${1:?Cach dung: ./cap-nhat.sh <MSSV>   (vi du: ./cap-nhat.sh k23)}"
cd "$(dirname "$0")"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "LOI: thu muc nay khong nam trong mot kho git."
  echo "     Co the ban da CHEP thu muc bai6 ra ngoai thay vi clone."
  echo "     Chay lai Khoi 1 o muc 2.6 de lay lai dung cach."
  exit 1
fi

# ---------------------------------------------------------------------
# cai-dat.sh da thay chuoi MSSV thanh ma so that NGAY TRONG cay lam viec.
# Voi git thi do la "file da bi sua", nen git pull se tu choi de khong
# de len cong cua ban. Tra chung ve ban goc truoc, keo ve xong thay lai.
#
# Day cung la mot bai hoc that: dung sinh file cau hinh de len chinh
# file dang duoc quan ly phien ban. Cach lam sach hon la sinh ra thu muc
# rieng -- nhung o quy mo bai lab, tra-ve-ban-goc la du va de hieu hon.
# ---------------------------------------------------------------------
echo "==> Tra sql/ va ra-soat/ ve ban goc"
git checkout -- sql ra-soat 2>/dev/null || true

echo "==> Keo ban moi tu GitHub"
if ! git pull --ff-only; then
  echo
  echo "LOI: khong keo ve duoc. Hai nguyen nhan thuong gap:"
  echo "  1. May ao khong ra duoc Internet -- thu:  ping -c1 github.com"
  echo "  2. Ban da tu sua mot file khac ngoai sql/ va ra-soat/."
  echo "     Xem file nao:  git status --short"
  echo "     Bo het sua doi:  git reset --hard origin/main"
  exit 1
fi

echo "==> Thay lai MSSV = $MSSV"
sed -i "s/MSSV/$MSSV/g" sql/*.sql ra-soat/*.sql
chmod +x ./*.sh backup/*.sh 2>/dev/null || true

cat <<HD

==================================================================
 DA CAP NHAT XONG -- stack van dang chay, du lieu con nguyen
==================================================================
 Neu ban cap nhat co sua file trong sql/ thi nap lai phan quyen:
     ./cai-dat.sh $MSSV --giu     # giu du lieu, chi nap lai RBAC

 Roi kiem chung lai:
     ./kiem-tra.sh $MSSV
HD

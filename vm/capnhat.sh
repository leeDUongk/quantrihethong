#!/usr/bin/env bash
# Kéo phiên bản mới nhất của theme từ GitHub về máy ảo và ghi lại mã commit
# để bảng phiên bản trên website hiển thị đúng.
#
# Cài đặt một lần:  chmod +x ~/capnhat.sh
# Dùng:             ~/capnhat.sh
set -e

# Sửa cho khớp tên thư mục repo của mình
REPO=~/quantrihethong-<MSSV>

echo "==> Kéo mã nguồn mới nhất"
cd "$REPO"
git pull --ff-only

echo "==> Ghi mã commit vào theme"
git log -1 --format='%h  %s  (%ad)' --date=format:'%H:%M %d/%m' \
  > "$REPO/wp-content/themes/k23/COMMIT.txt"

echo "==> Phiên bản hiện tại trên máy chủ:"
cat "$REPO/wp-content/themes/k23/COMMIT.txt"

echo
echo "Xong. Tải lại trang trên Firefox (Ctrl+F5) để thấy thay đổi."

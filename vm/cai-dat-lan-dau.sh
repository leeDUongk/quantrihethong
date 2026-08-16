#!/usr/bin/env bash
# Chạy MỘT LẦN trên máy ảo Ubuntu để nối máy ảo với repo GitHub.
set -e

REPO_URL=https://github.com/leeDUongk/quantrihethong.git
WP_DIR=~/bai3/wordpress-lab

echo "==> 1. Kéo repo GitHub về thư mục nhà"
cd ~
[ -d ~/quantrihethong ] || git clone "$REPO_URL" quantrihethong
cd ~/quantrihethong && git pull --ff-only

echo "==> 2. Đặt file override vào thư mục wordpress-lab"
cp ~/quantrihethong/vm/docker-compose.override.yml "$WP_DIR/"

echo "==> 3. Đặt script cập nhật vào thư mục nhà"
cp ~/quantrihethong/vm/capnhat.sh ~/capnhat.sh
chmod +x ~/capnhat.sh

echo "==> 4. Dựng lại stack WordPress kèm theme gắn từ GitHub"
cd "$WP_DIR"
docker compose up -d
docker compose ps

echo
echo "==> 5. Kiểm tra theme đã vào trong container chưa"
docker compose exec wordpress ls -l /var/www/html/wp-content/themes/

echo
echo "Xong. Vào http://localhost:8081/wp-admin -> Giao diện -> Themes -> kích hoạt K23"

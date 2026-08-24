# Bài lab 5 — Reverse Proxy và Nginx Proxy Manager

Khung cấu hình đi kèm tài liệu `b5-bai-lab-proxy-npm.docx`.
Mục đích: khỏi phải gõ YAML trong terminal Ubuntu — sai một dấu cách là hỏng cả file.

## Lấy về

```bash
cd ~
git clone https://github.com/<tai-khoan-giang-vien>/quantrihethong.git khung-bai5
cp -r khung-bai5/bai5 ~/npm-lab
cd ~/npm-lab
```

## Cấu trúc

| Đường dẫn | Nội dung | Việc phải làm |
|---|---|---|
| `proxy/docker-compose.yml` | Stack Nginx Proxy Manager, phiên bản cố định `2.11.3` | Không cần sửa |
| `proxy/custom/http.conf` | `limit_req_zone` — mục 8.3 | Đổi `MSSV` thành mã của mình |
| `static-site/` | Website tĩnh làm mẫu chứng | Sửa `html/index.html` |
| `patch/php-web-app.yml` | Bản đã sửa cho `~/bai3/php-web-app` | **Diff rồi mới chép đè** |
| `patch/wordpress-lab.yml` | Bản đã sửa cho `~/bai3/wordpress-lab` | **Diff rồi mới chép đè** |
| `patch/cuu-ho.yml` | Stack tối giản cho ai chưa hoàn thành Bài lab 3 | Chỉ dùng khi đi **đường B**, mục 2.2 |
| `tao-chung-chi.sh` | Sinh chứng chỉ tự ký có SAN 5 tên miền | `./tao-chung-chi.sh <MSSV>` |
| `kiem-tra.sh` | Chạy toàn bộ lệnh kiểm chứng mục 5.6 và 6.5 | `./kiem-tra.sh <MSSV>` |

## Thứ tự làm

```bash
# 0. Đổi MSSV trong hai chỗ
sed -i 's/MSSV/k23/g' proxy/custom/http.conf static-site/html/index.html

# 1. Network dùng chung — làm trước tiên
docker network create npm_network

# 2. Dựng proxy
cd proxy && docker compose up -d && cd ..

# 3. Website tĩnh
cd static-site && docker compose up -d && cd ..

# 4. Đối chiếu rồi sửa hai stack của Bài lab 3
diff ~/bai3/php-web-app/docker-compose.yml   patch/php-web-app.yml
diff ~/bai3/wordpress-lab/docker-compose.yml patch/wordpress-lab.yml

# 5. Chứng chỉ tự ký
./tao-chung-chi.sh k23

# 6. Kiểm tra sau mỗi bước lớn
./kiem-tra.sh k23
```

## Chưa hoàn thành Bài lab 3?

```bash
docker compose -f ~/npm-lab/patch/cuu-ho.yml up -d
```

Dựng bốn container cùng tên với Bài lab 3 nhưng **dữ liệu trống**, để các mục sau vẫn chạy được.
Đổi lại, phần nghiệm thu "dữ liệu cũ còn nguyên" ở mục 6.4 sẽ không chứng minh được.

## Cảnh báo

- **Không chạy `docker compose down -v`** ở hai thư mục của Bài lab 3 — cờ `-v` xóa volume, tức xóa dữ liệu WordPress và bảng `sinhvien` của Bài lab 2.
- **Không chép đè `patch/*.yml` mà chưa `diff`** — nếu đã tự đổi tên container hoặc tên network ở Bài lab 3 thì phải sửa lại cho khớp.
- Hai file trong `certs/` bị `.gitignore` loại ra: khóa riêng không bao giờ đưa lên kho mã nguồn.

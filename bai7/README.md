# Bài lab 7 — Giám sát hệ thống với Prometheus và Grafana

Học phần **Triển khai và quản trị hệ thống phần mềm — SDM332**, Chương 7.
Gắn với **Mốc 7** của dự án cuối học phần.

Bài lab dựng một hệ thống WordPress + MySQL, rồi đặt một tầng giám sát lên
trên nó: Prometheus thu thập, Grafana hiển thị, ba exporter cung cấp số liệu.

## Hệ thống gồm những gì

| Dịch vụ | Ảnh | Nghe ở đâu | Vai trò |
|---|---|---|---|
| `wordpress` | `wordpress:php8.3-apache` | `0.0.0.0:8080` | Ứng dụng được giám sát |
| `mysql-db` | `mysql:8.0` | không phơi | CSDL của WordPress |
| `prometheus` | `prom/prometheus:latest` | `127.0.0.1:9090` | Thu thập và lưu chỉ số |
| `grafana` | `grafana/grafana:latest` | `127.0.0.1:3000` | Vẽ dashboard |
| `node-exporter` | `prom/node-exporter:latest` | không phơi | Chỉ số của **máy ảo** |
| `cadvisor` | `ghcr.io/google/cadvisor:latest` | không phơi | Chỉ số của **từng container** |
| `mysql-exporter` | `prom/mysqld-exporter:latest` | không phơi | Chỉ số của **MySQL** |

Ba network: `db_net` (internal, không ra Internet), `web_net` (chỉ để công bố
cổng 8080), `monitor_net`. `mysql-exporter` là container duy nhất nằm ở cả
`db_net` lẫn `monitor_net` — nhờ vậy Prometheus không bao giờ chạm được vào MySQL.

## Yêu cầu môi trường

- Máy ảo Ubuntu 22.04 hoặc 24.04, **cài mới**, không cần bất cứ thứ gì của bài lab 1–6
- Tối thiểu 4 GB RAM và 20 GB đĩa trống
- Máy ảo ra được Internet để tải image

## Cài đặt

```bash
# 0. Cai Docker tren may ao trang (chay MOT LAN)
./cai-dat-docker.sh
newgrp docker            # hoac dang xuat ra vao lai

# 1. Dung toan bo he thong -- thay k23 bang ma so sinh vien cua minh
./cai-dat.sh k23

# 2. Kiem chung
./kiem-tra.sh k23

# 3. Sinh tai gia de chung minh bieu do phan anh he thong that
./tao-tai.sh 120
```

## Truy cập

WordPress phơi thẳng ra ngoài:

```
http://<IP-may-ao>:8080
```

Prometheus và Grafana **chỉ nghe trên `127.0.0.1`** — đây là yêu cầu của Mốc 7,
không phải giới hạn kỹ thuật. Từ máy thật, mở một đường hầm SSH:

```bash
ssh -L 9090:127.0.0.1:9090 -L 3000:127.0.0.1:3000 <user>@<IP-may-ao>
```

rồi mở trên máy thật:

- Prometheus — <http://localhost:9090>
- Grafana — <http://localhost:3000>

Mật khẩu Grafana sinh từ mã số sinh viên, xem trong file `.env` do
`cai-dat.sh` tạo ra.

## Các script khác

| Script | Việc nó làm |
|---|---|
| `./don-dep.sh` | Đưa Docker về trạng thái trống. `--tat-ca` xoá cả image |
| `./cap-nhat.sh k23` | Kéo bản sửa mới từ GitHub, không dừng stack |
| `./tao-tai.sh 120` | Sinh tải CPU và tải truy vấn trong 120 giây |

## Hai điểm khác với giáo trình — đọc trước khi thắc mắc

**`DATA_SOURCE_NAME` không còn dùng được.** Giáo trình mô tả cách cấu hình
`mysql-exporter` bằng biến môi trường `DATA_SOURCE_NAME`. Biến này đã bị bỏ
từ `mysqld_exporter` **0.15.0** (2023). Bài lab dùng file `.my.cnf` thay thế —
file đó do `cai-dat.sh` sinh ra, không commit lên Git.

**cAdvisor đã đổi kho ảnh.** Từ `v0.53.0`, ảnh chuyển từ
`gcr.io/cadvisor/cadvisor` sang `ghcr.io/google/cadvisor`.

## Về phiên bản image

Các ảnh dùng thẻ `latest` để bài lab **cài được ngay trên mọi máy**. Nhưng `latest`
hôm nay và `latest` tháng sau có thể là hai bản khác nhau — nghĩa là hệ thống
không tái lập được.

Cách xử lý: `cai-dat.sh` ghi lại **đúng bản đã nhận kèm mã băm** vào
`phien-ban-da-dung.txt`. File đó commit vào repo. Khi cần dựng lại y hệt hệ thống
của hôm nay — ví dụ để điều tra một sự cố — thì ghim theo mã băm trong file đó.

Mã băm chặt hơn số phiên bản: một thẻ như `v3.14.0` về lý thuyết vẫn có thể bị
đẩy lại trỏ sang nội dung khác; `sha256:...` thì không — nó *chính là* nội dung.

## Sản phẩm nộp

Xem mục 5 của tài liệu bài lab. Tối thiểu:

- Ảnh Prometheus → Targets, bốn target đều `UP`
- Ảnh dashboard Grafana, khung thời gian **Last 24 hours**, đường liên tục
- Ảnh trước và sau khi chạy `./tao-tai.sh`, thấy rõ đỉnh CPU đúng khoảng giờ
- File `monitoring/grafana/dashboards/*.json` trong repo

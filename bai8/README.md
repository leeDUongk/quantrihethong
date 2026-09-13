# Bài lab 8 — Quản lý log tập trung và cảnh báo sự cố

Học phần **Triển khai và quản trị hệ thống phần mềm — SDM332**, Chương 8.
Gắn với **Mốc 8** của dự án cuối học phần.

**Bài này kế thừa bài lab 7.** Không dựng lại máy ảo, không xoá dữ liệu.
Ba dịch vụ mới đặt lên trên hệ thống giám sát đã có.

## Cái gì làm tiếp, cái gì không làm lại

| Việc | Bài 7 | Bài 8 |
|---|---|---|
| Cài Docker (`cai-dat-docker.sh`) | đã làm | **không làm lại** |
| Dựng WordPress + MySQL | đã làm | **không làm lại** — dữ liệu giữ nguyên |
| Prometheus + Grafana + 3 exporter | đã làm | **không làm lại** — chuỗi dữ liệu 24h giữ nguyên |
| Tài khoản `exporter_<MSSV>` trong MySQL | đã làm | **không làm lại** |
| Dashboard tổng quan hệ thống | đã làm | giữ nguyên, nạp lại từ file |
| Thu thập log tập trung | — | **mới**: Loki + Promtail |
| Alerting rule | — | **mới**: `monitoring/rules/alerts.yml` |
| Gửi cảnh báo | — | **mới**: Alertmanager + bộ nhận nội bộ |

Lý do giữ nguyên dữ liệu: **Mốc 7 của dự án đòi dashboard có dữ liệu liên tục ít
nhất 24 giờ.** Xoá stack là mất chuỗi đó và phải chờ lại một ngày. Vì vậy
`cai-dat.sh` của bài 8 **không có** chế độ "cài sạch" như bài 7.

Kỹ thuật giữ được dữ liệu: `docker-compose.yml` của bài 8 khai **cùng
`name: bai7-lab`** và **cùng tên volume** với bài 7. Compose nhận ra bảy
container cũ vẫn đúng cấu hình nên để yên, chỉ tạo bốn container mới.

## Hệ thống sau bài 8 gồm những gì

Bảy dịch vụ cũ của bài 7, cộng bốn dịch vụ mới:

| Dịch vụ | Ảnh | Nghe ở đâu | Vai trò |
|---|---|---|---|
| `loki` | `grafana/loki:latest` | `127.0.0.1:3100` | Kho log tập trung |
| `promtail` | `grafana/promtail:latest` | không phơi | Đọc log mọi container, đẩy về Loki |
| `alertmanager` | `prom/alertmanager:latest` | `127.0.0.1:9093` | Gom nhóm, khử trùng lặp, gửi cảnh báo |
| `bao-dong` | `python:3.12-alpine` | `127.0.0.1:5001` | Bộ nhận cảnh báo nội bộ |

## Cài đặt

```bash
# 0. Lay ma nguon bai 8 (mot lan)
git clone --depth 1 https://github.com/leeDUongk/quantrihethong.git ~/kho-qths
git -C ~/kho-qths config core.fileMode false
ln -s ~/kho-qths/bai8 ~/canh-bao
cd ~/canh-bao && chmod +x *.sh

# 1. Cai dat -- thay k23 bang ma so sinh vien
./cai-dat.sh k23

# 2. Kiem chung
./kiem-tra.sh k23

# 3. Gay su co that de canh bao keu
./tao-loi.sh dung-exporter
```

Nếu đã clone ở bài 7 thì bỏ qua bước `git clone`, chỉ cần:

```bash
git -C ~/kho-qths pull
ln -s ~/kho-qths/bai8 ~/canh-bao
cd ~/canh-bao && chmod +x *.sh && ./cai-dat.sh k23
```

## Truy cập

Tất cả đều **chạy cục bộ trong máy ảo**, không cần tên miền, không cần SSL.

```
http://localhost:3000     Grafana        (admin / Grafana_<MSSV>_2026)
http://localhost:9090     Prometheus     (mục Alerts)
http://localhost:9093     Alertmanager
http://localhost:5001     Bảng báo động  <-- cảnh báo hiện ở đây
```

Máy ảo chỉ có dòng lệnh thì mở đường hầm SSH từ máy thật:

```bash
ssh -L 3000:127.0.0.1:3000 -L 9090:127.0.0.1:9090 \
    -L 9093:127.0.0.1:9093 -L 5001:127.0.0.1:5001 <user>@<IP-may-ao>
```

## Bốn lỗi trong mã của giáo trình — đã sửa

Mã alert rule in trong giáo trình có bốn chỗ không chạy đúng. Bản gốc để ở
`monitoring/rules/00-vi-du-sai.yml.mau` (đuôi `.mau` nên Prometheus không nạp)
để đối chiếu ở Bước 8.

**1. Sai tên nhãn.** Giáo trình dùng `container="wordpress"`; cAdvisor gắn nhãn
**`name`**, không phải `container`. Biểu thức không khớp chuỗi nào, rule nằm im
vĩnh viễn, và **Prometheus không báo lỗi** — hệ cảnh báo trông như đang chạy tốt.

**2. Chia cho không.** `container_spec_memory_limit_bytes` bằng **0** khi
container không đặt giới hạn RAM — đúng trường hợp bài lab. Trong Prometheus, số
dương chia 0 ra `+Inf`, mà `+Inf > 85` là **đúng**. Cảnh báo kêu ngay từ giây đầu
và kêu mãi. Còn tệ hơn là không kêu.

**3. Chỉ số không tồn tại.** `mysql_global_status_errors_total` không có trong
mysqld_exporter. Cái gần nhất và có thật là
`mysql_global_status_connection_errors_total`.

**4. Ngưỡng tuyệt đối.** `threads_connected > 80` chỉ đúng khi `max_connections`
bằng mặc định 151. Đổi sang phần trăm thì rule còn đúng cả khi người quản trị
chỉnh `max_connections`.

## Hai điểm khác nữa so với giáo trình

**Loki 3.x dùng `tsdb` + schema `v13`.** Giáo trình viết `boltdb-shipper` + `v12`
— giá trị của Loki 2.x, nay đã lỗi thời và sẽ bị bỏ.

**Cảnh báo demo bằng webhook nội bộ, không phải Gmail.** Gmail đòi App Password
và cổng 587 thường bị chặn trong mạng trường — sinh viên cấu hình đúng hết mà
không bao giờ nhận được mail. Bộ nhận ở `bao-dong/nhan-canh-bao.py` chạy 100%
offline. Muốn thêm Telegram thì `./cai-dat.sh <MSSV> --telegram`.

## Các script

| Script | Việc nó làm |
|---|---|
| `./cai-dat.sh k23` | Dựng tầng log và cảnh báo, **không xoá dữ liệu bài 7** |
| `./cai-dat.sh k23 --telegram` | Gửi cảnh báo thêm về Telegram |
| `./kiem-tra.sh k23` | Chín phép thử, in `(DUNG)` hoặc `(SAI)` từng mục |
| `./tao-loi.sh dung-exporter` | Dừng exporter → cảnh báo `DichVuChet` kêu thật |
| `./tao-loi.sh sai-mat-khau` | Exporter sống nhưng mù → `MySQLKhongDangNhapDuoc` |
| `./tao-loi.sh cpu` | Đốt CPU → `ContainerCPUCao` |
| `./tao-loi.sh log-loi` | Bơm log có chữ ERROR vào Loki |
| `./tao-loi.sh sua-het` | Trả mọi thứ về bình thường |
| `./cap-nhat.sh k23` | Kéo bản sửa mới từ GitHub |

## Sản phẩm nộp

Xem mục 5 của tài liệu bài lab. Tối thiểu:

- Ảnh `docker compose ps` — **mười một container** đang chạy
- Ảnh Prometheus → Targets, **sáu target** đều `UP`
- Ảnh Grafana → Explore với truy vấn LogQL trả về log thật
- Ảnh Prometheus → Alerts lúc một rule đang **FIRING**
- Ảnh bảng báo động `http://localhost:5001` có cả dòng đỏ (`firing`) và dòng xanh (`resolved`)
- File `monitoring/rules/alerts.yml` trong repo

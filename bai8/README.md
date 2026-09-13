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

Lý do giữ nguyên dữ liệu: Prometheus không biết gì về quá khứ trước khi nó chạy,
nên xoá volume là mất sạch số liệu đã ghi — và số liệu đó không tạo lại được. Vì
vậy `cai-dat.sh` của bài 8 **không có** chế độ "cài sạch" như bài 7.

**Tắt máy ảo thì không mất gì** — volume còn nguyên, các container tự chạy lại
khi bật máy. Chỉ có khoảng trống trên biểu đồ đúng bằng lúc máy tắt, và điều đó
không cản trở bài lab 8. **Bài 8 chạy được cả khi chưa có dữ liệu cũ nào.**

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

Đã làm xong bài 7 và đã tắt máy. Bật máy ảo lên rồi chạy **bốn lệnh** này:

```bash
# 1. KEO MA NGUON BAI 8 TU GITHUB VE.
#    bai8/ nam trong CUNG MOT kho voi bai7/. Kho da co tai ~/kho-qths tu
#    bai 7, nhung luc do chua co bai8/ nen phai keo ban moi.
#    cap-nhat.sh goi "git pull" ben trong, va tra monitoring/ ve ban goc
#    truoc khi keo de tranh xung dot voi cho da thay MSSV.
cd ~/giam-sat && ./cap-nhat.sh k23

# 2. Tao duong tat ~/canh-bao tro vao bai8 (giong ~/giam-sat cua bai 7)
[ -e ~/canh-bao ] || ln -s ~/kho-qths/bai8 ~/canh-bao

# 3. Vao thu muc lam viec va cap quyen chay
cd ~/canh-bao && chmod +x *.sh

# 4. Dung them bon dich vu moi -- thay k23 bang ma so sinh vien
./cai-dat.sh k23
```

Rồi kiểm chứng và gây sự cố thật để cảnh báo kêu:

```bash
./kiem-tra.sh k23
./tao-loi.sh dung-exporter
```

**Không cần** chạy lại `cai-dat-docker.sh` hay `cai-dat.sh` của bài 7. Bảy
container cũ tự chạy lại khi máy ảo khởi động, nhờ `restart: unless-stopped`.

**Nếu máy ảo chưa từng `git clone`** (làm bài 7 bằng cách chép file) thì thay
lệnh 1 bằng:

```bash
git clone --depth 1 https://github.com/leeDUongk/quantrihethong.git ~/kho-qths
git -C ~/kho-qths config core.fileMode false
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

## Ghi chú kỹ thuật

**Alert rule.** Xem `monitoring/rules/alerts.yml` — tám rule, mỗi rule có chú
thích vì sao chọn biểu thức và ngưỡng đó. Kiểm cú pháp trước khi nạp lại:

```bash
docker compose exec -T prometheus promtool check rules /etc/prometheus/rules/alerts.yml
docker compose exec -T prometheus wget -q --post-data="" -O- http://localhost:9090/-/reload
```

**Loki 3.x.** Cấu hình dùng `tsdb` + schema `v13`. Hai dòng dễ bỏ sót:
`limits_config.allow_structured_metadata: true` (bắt buộc với `v13`) và
`compactor.delete_request_store: filesystem` — thiếu dòng sau thì
`retention_period` được nhận nhưng **không bao giờ xoá** dữ liệu cũ.

**Kênh gửi cảnh báo.** Mặc định là webhook nội bộ tới `bao-dong` — chạy hoàn
toàn offline, không cần tài khoản nào. Thêm Telegram thì
`./cai-dat.sh <MSSV> --telegram`.

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

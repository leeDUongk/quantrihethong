# Bài lab 6 — Quản trị cơ sở dữ liệu: tài khoản, phân quyền và RBAC

Khung cấu hình và script SQL đi kèm tài liệu `b6-bai-lab-csdl-rbac.docx`.
Mục đích: khỏi phải gõ hàng trăm dòng SQL trong terminal Ubuntu.

## Bốn khối lệnh — chép nguyên khối

```bash
# 1. Kéo mã nguồn về
cd ~
git clone https://github.com/leeDUongk/quantrihethong.git khung-lab \
  || (cd ~/khung-lab && git pull)
cp -r ~/khung-lab/bai6 ~/db-lab
cd ~/db-lab && chmod +x *.sh backup/*.sh

# 2. Dọn sạch máy ảo (bỏ qua nếu máy còn mới)
./don-dep.sh

# 3. Cài đặt — thay k23 bằng MSSV của mình, đây là chỗ DUY NHẤT phải sửa
./cai-dat.sh k23

# 4. Kiểm chứng
./kiem-tra.sh k23
```

`cai-dat.sh` tự làm: chép `.env`, thay `MSSV`, `docker compose up -d`, **chờ cả hai DBMS
báo healthy**, nạp RBAC cho MySQL và PostgreSQL, bật Row Level Security, rồi in ra
địa chỉ truy cập và ba tài khoản để thử quyền.

> Chạy script không thay được việc hiểu. Bốn khối trên đưa hệ thống về trạng thái đúng
> trong khoảng năm phút, nhưng phần được chấm là bảy câu giải trình ở mục 13.2 —
> **không trả lời được nếu chỉ chạy script**.

## Cấu trúc

| Đường dẫn | Nội dung | Mục |
|---|---|---|
| `docker-compose.yml` | MySQL 8 + PostgreSQL 16 + phpMyAdmin + pgAdmin, hai mạng tách bạch | 4.1 |
| `sql/01-mysql-dulieu.sql` | Bảng và dữ liệu mẫu — **tự chạy** lúc khởi tạo | 5.2 |
| `sql/02-mysql-rbac.sql` | Ba vai trò phân cấp, ba người dùng, `SET DEFAULT ROLE` | 5.3–5.5 |
| `sql/03-postgres-dulieu.sql` | Bảng và dữ liệu mẫu — **tự chạy** lúc khởi tạo | 6.1 |
| `sql/04-postgres-rbac.sql` | Cùng mô hình vai trò, ba tầng quyền, `ALTER DEFAULT PRIVILEGES` | 6.3–6.4 |
| `sql/05-postgres-rls.sql` | Row Level Security — lọc tới từng dòng | 6.6 |
| `backup/sao-luu.sh` | Sao lưu cả hai CSDL, giữ 7 bản gần nhất | 8.1 |
| `backup/khoi-phuc.sh` | Khôi phục **và in ra số dòng trước/sau** làm bằng chứng | 8.2 |
| `ra-soat/mysql-ra-soat.sql` | Bốn truy vấn kiểm toán quyền | 9.2 |
| `ra-soat/pg-ra-soat.sql` | Năm truy vấn kiểm toán quyền | 9.2 |
| `don-dep.sh` | **Bước 0** — dọn sạch container/volume của các bài lab trước | 2.2 |
| `cai-dat.sh` | Cài đặt một mạch, không phải gõ tay | 2.6 |
| `kiem-tra.sh` | Kiểm chứng toàn bộ, in ra `(DUNG)` / `(SAI)` cho từng mục | 2.6 |

## Làm thủ công từng bước

Nạp biến môi trường một lần cho mỗi phiên terminal — sau đó mọi lệnh chép–dán chạy được:

```bash
cd ~/db-lab && set -a && source .env && set +a
```

```bash
# Thử quyền bằng từng tài khoản — PHẦN QUAN TRỌNG NHẤT của bài lab
docker compose exec mysql-db mysql -u an_k23    -p"MatKhau_An_k23!"    "$APP_DB"
docker compose exec mysql-db mysql -u binh_k23  -p"MatKhau_Binh_k23!"  "$APP_DB"
docker compose exec mysql-db mysql -u cuong_k23 -p"MatKhau_Cuong_k23!" "$APP_DB"
docker compose exec postgres-db psql -U an_k23 -d "$APP_DB"

# Sao lưu và khôi phục thật
./backup/sao-luu.sh
./backup/khoi-phuc.sh "$(ls -t backup/mysql-*.sql | head -1)"

# Rà soát quyền
docker compose exec -T mysql-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" < ra-soat/mysql-ra-soat.sql
docker compose exec -T postgres-db psql -U postgres -d "$APP_DB" < ra-soat/pg-ra-soat.sql
```

## Ba điều hay sai

1. **Quên `SET DEFAULT ROLE` trên MySQL** — đăng nhập được nhưng không có quyền gì.
   File `02-mysql-rbac.sql` đã có sẵn dòng này; nếu tự gõ tay thì đừng quên.
2. **Quên `GRANT USAGE ON SCHEMA public` trên PostgreSQL** — báo
   `permission denied for schema public` dù đã cấp `SELECT` trên bảng.
3. **Sửa file `sql/01` hoặc `sql/03` rồi khởi động lại mà không thấy đổi gì** —
   script trong `initdb.d` **chỉ chạy khi volume còn trống**. Muốn nạp lại phải
   `docker compose down -v`, và lệnh đó **xóa toàn bộ dữ liệu**.

## Cảnh báo

- `.env` chứa mật khẩu thật, đã nằm trong `.gitignore` — không bao giờ đưa lên kho mã nguồn.
- `PGADMIN_CONFIG_SERVER_MODE: "False"` bỏ bước đăng nhập của pgAdmin cho tiện trong lab.
  **Không dùng thiết lập này trên hệ thống thật.**
- Hai cổng `8080` và `8081` mở ra ngoài chỉ để học cho nhanh. Trong dự án cuối học phần,
  công cụ quản trị CSDL **bắt buộc** nằm sau reverse proxy và có Access List (Bài lab 5).
- Bản sao lưu nằm cùng máy ảo với CSDL thì **chưa phải là sao lưu** — hỏng ổ đĩa là mất cả hai.

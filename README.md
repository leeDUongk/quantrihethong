# Kịch bản demo — Từ máy tính tới máy chủ qua GitHub

Repo này chứa **theme WordPress K23** và các script để nối ba nơi thành một vòng lặp:

```
Máy Windows (Desktop)          GitHub                Máy ảo Ubuntu (VMware)
─────────────────────          ──────                ──────────────────────
Claude sinh/sửa code    ──►    quantrihethong   ──►  git pull  ──►  WordPress
GitHub Desktop: push           (bản chính)           ~/capnhat.sh    Firefox thấy đổi
```

Điểm mấu chốt: thư mục theme trên máy ảo được **gắn thẳng** vào container bằng bind mount,
nên sửa file PHP là có hiệu lực ngay — không build lại image, không restart container.

---

## Cấu trúc repo

```
quantrihethong/
├── wp-content/themes/k23/     ← theme, phần Claude sinh code
│   ├── style.css
│   ├── functions.php          ← chứa K23_VERSION và K23_LAN_SUA
│   ├── header.php             ← bảng phiên bản hiện trên đầu mọi trang
│   ├── index.php              ← hộp demo, nơi đổi thông điệp
│   ├── footer.php
│   └── COMMIT.txt             ← script trên máy ảo tự ghi mã commit vào đây
├── vm/
│   ├── cai-dat-lan-dau.sh     ← chạy một lần trên máy ảo
│   ├── capnhat.sh             ← chạy mỗi lần muốn cập nhật
│   └── docker-compose.override.yml
├── .gitattributes             ← ép LF, tránh lỗi xuống dòng Windows/Linux
└── README.md
```

---

## Cài đặt một lần

### A. Trên máy Windows

Thư mục làm việc gợi ý: **`D:\hoc-tap\quantrihethong-<MSSV>`**

1. Mở **GitHub Desktop** → *File → Clone repository* → thẻ **URL** → dán đường dẫn repo
   **của chính mình**: `https://github.com/<tài-khoản-github>/quantrihethong-<MSSV>.git`
2. Ô *Local path* gõ đầy đủ `D:\hoc-tap\quantrihethong-<MSSV>` → **Clone**
3. Chép nội dung gói này vào chính thư mục đó, sao cho `wp-content\` và `vm\` nằm **ngay trong**
   thư mục repo, không lồng thêm một cấp nữa
4. GitHub Desktop hiện danh sách file mới → điền *Summary* → **Commit to main** → **Push origin**

> **Nếu thư mục repo nằm bên trong một repo Git khác**, Git của repo cha sẽ báo *embedded
> repository*. Xử lý bằng cách thêm tên thư mục đó vào `.gitignore` của repo cha. Cách gọn hơn:
> đặt thư mục dự án ở một nhánh cây thư mục riêng, không lồng vào repo nào khác.

### B. Trên máy ảo Ubuntu

```bash
cd ~
git clone https://github.com/<tài-khoản-github>/quantrihethong-<MSSV>.git
bash ~/quantrihethong-<MSSV>/vm/cai-dat-lan-dau.sh
```

Script làm bốn việc: kéo repo về, đặt file `docker-compose.override.yml` vào `~/bai3/wordpress-lab/`,
đặt `capnhat.sh` vào thư mục nhà, rồi `docker compose up -d` để gắn theme vào container.

### C. Kích hoạt theme

Mở `http://localhost:8081/wp-admin` → **Giao diện → Themes** → thấy **K23** → **Kích hoạt**.

Vào `http://localhost:8081` phải thấy dải màu xanh trên cùng ghi phiên bản, lần sửa, mã commit,
tên máy chủ và giờ tải trang.

---

## Vòng lặp demo trước lớp

Mỗi vòng mất khoảng một phút.

| Bước | Làm ở đâu | Việc |
|---|---|---|
| 1 | Máy Windows | Sửa `functions.php`: đổi `K23_LAN_SUA` thành *"Sửa lần 1 — buổi học ngày ..."* và `K23_MAU_NEN` thành `#C0392B` |
| 2 | GitHub Desktop | Xem phần **Changes** — chỉ ra cho lớp thấy đúng những dòng vừa đổi |
| 3 | GitHub Desktop | Commit → Push origin |
| 4 | Trình duyệt | Mở repo trên github.com, chỉ ra commit vừa lên và nội dung file đã đổi |
| 5 | Máy ảo Ubuntu | `~/capnhat.sh` — in ra mã commit vừa kéo về |
| 6 | Firefox trên máy ảo | Ctrl+F5 → dải trên cùng đổi màu đỏ, dòng *Lần sửa* và *Commit* đổi theo |

**Ba chỗ đổi rõ nhất, nên dùng cho ba vòng demo khác nhau:**

- `K23_LAN_SUA` trong `functions.php` — đổi chữ, thấy ngay trên dải
- `K23_MAU_NEN` trong `functions.php` — đổi màu toàn trang, hiệu ứng thị giác mạnh nhất
- Dòng *"Thông điệp hiện tại"* trong `index.php` — đổi nội dung giữa trang

---

## Vì sao không cần restart container

`docker-compose.override.yml` gắn thư mục theme theo kiểu **bind mount**:

```yaml
- ${HOME}/<thư-mục-repo>/wp-content/themes/k23:/var/www/html/wp-content/themes/k23:ro
```

Thư mục trên máy ảo và thư mục trong container là **cùng một chỗ trên đĩa**. PHP là ngôn ngữ
thông dịch, Apache đọc lại file mỗi lần có yêu cầu, nên file đổi là trang đổi. Hậu tố `:ro`
cho container quyền đọc chứ không cho ghi — WordPress không sửa được theme từ trang quản trị,
mọi thay đổi bắt buộc đi qua Git. Đó chính là bài học cần dạy.

So sánh với Bài lab 2: ở đó sửa mã nguồn phải `docker build` lại image rồi chạy container mới.
Ở đây bind mount bỏ hẳn hai bước đó — đổi lại, thứ nằm trong bind mount **không được đóng gói
vào image**, nên cách này chỉ hợp môi trường phát triển, không dùng khi triển khai thật.

---

## Câu hỏi thảo luận cho sinh viên

1. Vì sao mã nguồn theme nằm trên GitHub còn nội dung bài viết lại không? Bài viết nằm ở đâu?
2. Nếu xóa container `wp-app` rồi `docker compose up -d`, theme còn không? Bài viết còn không? Vì sao khác nhau?
3. Hậu tố `:ro` ngăn được điều gì? Nếu bỏ đi thì rủi ro là gì khi làm việc nhóm?
4. Cách làm này khác gì so với `docker build` ở Bài lab 2? Trường hợp nào phải quay lại dùng build?
5. Bước 5 đang làm tay bằng `~/capnhat.sh`. Muốn tự động hoàn toàn thì cần thêm thành phần nào?
   (gợi ý: webhook của GitHub, hoặc self-hosted runner của GitHub Actions — nội dung Bài lab 4)

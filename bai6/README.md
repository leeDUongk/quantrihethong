# Bai lab 6 -- Quan tri co so du lieu: tai khoan, phan quyen va RBAC

Bo ma nguon nay dung mot he thong **hoan toan moi**, khong dung lai bat cu
thu gi cua Bai lab 2, 3, 4, 5.

    MySQL 8.0  +  PostgreSQL 16  +  phpMyAdmin 5.2  +  pgAdmin 8.12
    hai mang tach bach: db_data (internal, khong ra Internet) va db_admin

## Cai dat -- bon khoi lenh, chep nguyen khoi

Khoi 1 -- keo ma nguon ve (xoa ban cu neu co, de bat dau tu trang thai sach):

    cd ~
    rm -rf ~/khung-lab ~/db-lab
    git clone --depth 1 https://github.com/leeDUongk/quantrihethong.git khung-lab
    cp -r ~/khung-lab/bai6 ~/db-lab
    cd ~/db-lab && chmod +x *.sh backup/*.sh && ls -a

Khoi 2 -- dua Docker ve trang thai trong:

    cd ~/db-lab && ./don-dep.sh

Khoi 3 -- cai dat. Thay k23 bang ma so sinh vien, day la cho DUY NHAT phai sua:

    cd ~/db-lab && ./cai-dat.sh k23

Khoi 4 -- kiem chung:

    cd ~/db-lab && ./kiem-tra.sh k23

## Ba script

| Script | Lam gi |
|---|---|
| `don-dep.sh` | Xoa moi container, volume, network cua Docker. Giu image de khoi tai lai. `--tat-ca` xoa ca image. |
| `cai-dat.sh` | Cai dat mot mach: thay MSSV, sinh `.env`, dung stack, cho toi khi DANG NHAP DUOC, nap RBAC va RLS. Chay lai bao nhieu lan cung ra dung ket qua. |
| `kiem-tra.sh` | Sau phep thu, in ra (DUNG) hoac (SAI) cho tung muc. |

`./cai-dat.sh k23 --giu` giu nguyen du lieu dang co va chi nap lai phan quyen.

## Vi sao cai-dat.sh khong con hong o buoc nap RBAC

Ba quyet dinh thiet ke, deu de tri mot loi that da gap:

1. **Mat khau chi ton tai o dung mot cho** -- cac bien trong chinh
   `cai-dat.sh`. Tu do script ghi ra `.env` cho Docker Compose va cung tu do
   truyen thang cho lenh `mysql` / `psql`. Script **khong** `source .env`,
   nen khong the co chuyen Compose va Bash doc ra hai chuoi khac nhau.
2. **Cat ky tu CR ngay tu dau.** File di qua Windows co the mang `\r` o cuoi
   dong; Compose cat bo con Bash thi giu lai -- lech mot ky tu vo hinh la du
   bao `Access denied`. File `.gitattributes` ep LF cho ca bo nguon.
3. **Cho toi khi dang nhap duoc, khong chi cho "healthy".** `mysqladmin ping`
   van bao song ca khi sai mat khau. Healthcheck trong `docker-compose.yml`
   va vong cho trong script deu **dang nhap that** bang chinh mat khau se
   dung o buoc sau.

Neu van hong, script dung ngay truoc khi nap SQL va in ra mat khau hai ben --
script dang dung va container dang giu -- de nhin la biet lech o dau.

## Ban goc cac file SQL

Lan chay dau, `cai-dat.sh` cat ban goc cua `sql/` va `ra-soat/` vao `.mau/`
roi moi thay chuoi `MSSV`. Nho vay chay lai voi ma so khac van dung, khong
bi "thay hai lan".

## Thu muc

    ~/db-lab/
      |-- docker-compose.yml    hai DBMS + hai cong cu quan tri
      |-- .env                  DO SCRIPT SINH RA -- khong dua len Git
      |-- .env.example          ban tham khao cho biet co nhung bien nao
      |-- sql/
      |   |-- 01-mysql-dulieu.sql     bang va du lieu mau (chay tu dong)
      |   |-- 02-mysql-rbac.sql       vai tro va tai khoan MySQL
      |   |-- 03-postgres-dulieu.sql
      |   |-- 04-postgres-rbac.sql
      |   +-- 05-postgres-rls.sql     Row Level Security
      |-- ra-soat/              truy van kiem toan quyen
      |-- backup/               sao-luu.sh va khoi-phuc.sh
      |-- don-dep.sh
      |-- cai-dat.sh
      +-- kiem-tra.sh

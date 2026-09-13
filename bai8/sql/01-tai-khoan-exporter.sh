#!/bin/bash
# =====================================================================
# Bai lab 7 -- Tai khoan rieng cho mysql-exporter
#
# File nay do anh mysql:8.0 tu chay MOT LAN DUY NHAT, luc thu muc du
# lieu con TRONG. Sua file roi khoi dong lai ma khong xoa volume thi
# khong co gi thay doi -- day la cai bay quen thuoc tu Bai lab 3.
#
# Dung .sh thay vi .sql vi can doc bien moi truong. File .sql trong
# initdb.d duoc nap nguyen van, khong thay bien.
#
# NGUYEN TAC DAC QUYEN TOI THIEU (Bai lab 6 muc 3.3) ap dung o day:
# exporter chi doc CHI SO van hanh, khong doc DU LIEU nghiep vu.
#   PROCESS            -- xem danh sach tien trinh dang chay
#   REPLICATION CLIENT -- xem trang thai nhan ban
#   SELECT             -- doc bang thong ke trong performance_schema
# KHONG cap INSERT, UPDATE, DELETE. Tai khoan giam sat bi chiem thi
# ke tan cong doc duoc so lieu, nhung khong sua duoc gi.
# =====================================================================
set -e

mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<SQL
CREATE USER IF NOT EXISTS '${EXPORTER_USER}'@'%'
  IDENTIFIED BY '${EXPORTER_PASSWORD}'
  WITH MAX_USER_CONNECTIONS 3;

GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO '${EXPORTER_USER}'@'%';
FLUSH PRIVILEGES;

SELECT CONCAT('Da tao tai khoan giam sat: ', '${EXPORTER_USER}') AS ket_qua;
SQL

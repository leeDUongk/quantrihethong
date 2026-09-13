#!/usr/bin/env bash
# =====================================================================
# Bai lab 8 -- GAY SU CO CO CHU DICH de chung minh he canh bao chay that
#
#   ./tao-loi.sh dung-wordpress    # dung WordPress -> DichVuChet? khong,
#                                  #   xem ghi chu ben duoi
#   ./tao-loi.sh dung-exporter     # dung mysql-exporter -> DichVuChet
#   ./tao-loi.sh sai-mat-khau      # exporter song nhung mu -> MySQLKhongDangNhapDuoc
#   ./tao-loi.sh cpu               # dot CPU -> ContainerCPUCao
#   ./tao-loi.sh log-loi           # bom dong log co chu ERROR vao Loki
#   ./tao-loi.sh sua-het           # tra moi thu ve binh thuong
#
# MOT BIEU DO DEP MA KHONG NHUC NHICH KHI HE THONG HONG THI CHUA CHUNG
# MINH DUOC GI. Day la buoc quan trong nhat cua bai lab 8.
# =====================================================================
set -u
cd "$(dirname "$0")"
VIEC="${1:-}"

gio() { date '+%H:%M:%S'; }

case "$VIEC" in

  dung-wordpress)
    echo "[$(gio)] Dung container wordpress."
    docker compose stop wordpress >/dev/null
    cat <<'HD'
------------------------------------------------------------------
 DIEU SE XAY RA -- va mot cho de nham lan:
 WordPress KHONG co exporter rieng, nen Prometheus khong co target
 nao tro toi no. Vi vay rule DichVuChet (up == 0) se KHONG keu.
 Cai thay doi la:
   - Bieu do "CPU tung container" mat duong wordpress
   - Log cua wordpress ngung chay vao Loki
 Day chinh la bai hoc: GIAM SAT CHI THAY NHUNG GI CO NGUOI DI DO.
 Muon biet WordPress con song hay khong thi phai them mot phep do --
 vi du blackbox-exporter goi HTTP vao no.
 Chay tiep:  ./tao-loi.sh dung-exporter   de thay mot canh bao keu that.
------------------------------------------------------------------
HD
    ;;

  dung-exporter)
    echo "[$(gio)] Dung container mysql-exporter.  <-- GHI LAI GIO NAY"
    docker compose stop mysql-exporter >/dev/null
    cat <<'HD'
------------------------------------------------------------------
 DIEU SE XAY RA, theo thu tu:
   ~15 giay : Prometheus lay so lieu that bai, up{job="mysql"} = 0
              Prometheus UI -> Alerts: DichVuChet chuyen sang PENDING
   ~75 giay : du "for: 1m", chuyen sang FIRING (mau do)
   ~105 giay: Alertmanager doi het "group_wait: 30s" roi gui di
              -> http://localhost:5001 hien mot dong mau do

 Vi sao phai doi lau vay? for: 1m la co y: mot lan lay so lieu truot
 khong phai la su co. Khong co "for" thi moi tram mang nho deu keu --
 va do la con duong ngan nhat den "met vi canh bao".

 Xong thi tra ve:  ./tao-loi.sh sua-het
------------------------------------------------------------------
HD
    ;;

  sai-mat-khau)
    echo "[$(gio)] Doi mat khau trong my.cnf thanh sai.  <-- GHI LAI GIO NAY"
    cp -f monitoring/my.cnf monitoring/my.cnf.that
    sed -i 's/^password = .*/password = MAT_KHAU_SAI/' monitoring/my.cnf
    docker compose restart mysql-exporter >/dev/null
    cat <<'HD'
------------------------------------------------------------------
 DIEU SE XAY RA:
   target mysql VAN "UP" (exporter con song, van tra loi Prometheus)
   nhung  mysql_up = 0  (exporter khong dang nhap duoc vao MySQL)
   -> rule MySQLKhongDangNhapDuoc keu, con DichVuChet thi KHONG.

 Phan biet hai trang thai nay la mot ky nang thuc su:
   target DOWN   = nguoi do da chet
   mysql_up = 0  = nguoi do con song nhung bi bit mat
 Hai su co khac han nhau, cach xu ly khac han nhau.

 Xong thi tra ve:  ./tao-loi.sh sua-het
------------------------------------------------------------------
HD
    ;;

  cpu)
    GIAY="${2:-240}"
    echo "[$(gio)] Dot CPU trong container wordpress $GIAY giay.  <-- GHI LAI GIO"
    docker compose exec -d wordpress \
      sh -c "timeout $GIAY sh -c 'while :; do :; done'" 2>/dev/null \
      || { echo "LOI: khong goi duoc wordpress. No dang chay chu?"; exit 1; }
    cat <<'HD'
------------------------------------------------------------------
 Rule ContainerCPUCao: > 70% lien tuc 2 phut. Cong them khoang nhin
 lai [2m] cua rate() va group_wait 30 giay, tong cong khoang BON PHUT
 tu luc bat dau den luc thong bao hien ra. Dung sot ruot.

 Trong luc cho, mo http://localhost:9090 -> Alerts de xem rule chuyen
 tu INACTIVE sang PENDING roi sang FIRING. Ba trang thai nay chinh la
 noi dung cot loi cua Buoc 9.
------------------------------------------------------------------
HD
    ;;

  log-loi)
    SO="${2:-30}"
    echo "[$(gio)] Bom $SO dong log co chu ERROR vao container wordpress."
    docker compose exec -T wordpress sh -c \
      "i=1; while [ \$i -le $SO ]; do \
         echo \"[\$(date '+%Y-%m-%d %H:%M:%S')] ERROR gia lap so \$i -- bai lab 8\" >&2; \
         i=\$((i+1)); sleep 1; done" 2>/dev/null &
    cat <<'HD'
------------------------------------------------------------------
 Sau khoang 30 giay, mo Grafana -> "Bai lab 8 — Log va canh bao":
   - Bieu do "So dong log CO TU 'error' moi giay" phai nho len
   - Bang log ben duoi hien dung nhung dong vua bom
 Truy van thu trong Explore:
   {container="wordpress"} |= "ERROR"
   {container="wordpress", muc="error"}
 Cau thu hai nhanh hon nhieu: no loc bang NHAN (da tach o buoc pipeline
 cua Promtail) chu khong phai doc het noi dung tung dong.
------------------------------------------------------------------
HD
    ;;

  sua-het)
    echo "[$(gio)] Tra moi thu ve binh thuong."
    [ -f monitoring/my.cnf.that ] && mv -f monitoring/my.cnf.that monitoring/my.cnf
    docker compose start wordpress mysql-exporter >/dev/null 2>&1 || true
    docker compose up -d >/dev/null
    echo
    echo " Doi khoang 1-2 phut roi kiem:"
    echo "   - http://localhost:9090 -> Alerts : moi rule ve INACTIVE"
    echo "   - http://localhost:5001            : co dong mau xanh 'resolved'"
    echo
    echo " Dong 'resolved' la bang chung Alertmanager theo doi ca luc su co"
    echo " KET THUC, khong chi luc no bat dau. Thieu send_resolved: true thi"
    echo " trang bao dong toan mau do va khong bao gio biet da yen."
    ;;

  *)
    sed -n '3,18p' "$0"
    exit 1
    ;;
esac

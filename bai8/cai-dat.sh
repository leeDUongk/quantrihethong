#!/usr/bin/env bash
# =====================================================================
# Bai lab 8 -- CAI DAT tang log va canh bao LEN TREN he thong cua bai 7.
#
#   ./cai-dat.sh k23              # cai va giu nguyen du lieu bai 7
#   ./cai-dat.sh k23 --telegram   # gui canh bao them ve Telegram
#   ./cai-dat.sh k23 --mo-lan     # pho giao dien ra mang (xem ghi chu)
#
# QUAN TRONG -- KHAC BAI 7. Script nay KHONG BAO GIO xoa du lieu. Bai 7
# co che do "cai sach" xoa het roi dung lai; bai 8 thi khong. Prometheus
# khong biet gi ve qua khu truoc khi no chay, nen xoa volume la mat sach
# so lieu da ghi -- va so lieu do khong tao lai duoc.
#
# Tat may ao thi KHONG mat gi: volume con nguyen, container tu chay lai
# khi bat may. Chi co khoang trong tren bieu do dung bang luc may tat.
#
# Chay bao nhieu lan cung ra dung mot ket qua.
# =====================================================================
set -euo pipefail

MSSV="${1:?Cach dung: ./cai-dat.sh <MSSV>   (vi du: ./cai-dat.sh k23)}"
case "$MSSV" in --*) echo "LOI: tham so dau tien phai la MSSV, khong phai co."; exit 1;; esac
TELEGRAM=0
MO_LAN=0
for t in "$@"; do
  [ "$t" = "--telegram" ] && TELEGRAM=1
  [ "$t" = "--mo-lan" ]   && MO_LAN=1
done

if [ "$MO_LAN" -eq 1 ]; then BIND_ADDR="0.0.0.0"; else BIND_ADDR="127.0.0.1"; fi
cd "$(dirname "$0")"

echo "=================================================================="
echo " BAI LAB 8 -- LOG TAP TRUNG VA CANH BAO   (MSSV = $MSSV)"
echo "=================================================================="

# ---------------------------------------------------------------------
# 0. Doi hoi ve moi truong
# ---------------------------------------------------------------------
if ! docker info >/dev/null 2>&1; then
  echo "LOI: khong goi duoc Docker."
  echo "     Chua cai   -> chay:  ../bai7/cai-dat-docker.sh"
  echo "     Da cai roi -> nhom docker chua co hieu luc, go:  newgrp docker"
  exit 1
fi

drv=$(docker info --format '{{.Driver}}')
if [ "$drv" != "overlay2" ]; then
  echo "!! Trinh luu tru o dia dang la \"$drv\", khong phai overlay2."
  echo "!! cAdvisor se khong tra duoc ten container. Xem muc Su co cua bai 7."
  echo
fi

# ---------------------------------------------------------------------
# 1. Chuan hoa xuong dong (file di qua Windows mang ky tu CR)
# ---------------------------------------------------------------------
find . -type f \( -name '*.sh' -o -name '*.sql' -o -name '*.yml' \
     -o -name '*.py' -o -name '*.cnf' -o -name '*.example' -o -name '.env' \) -print0 \
  | xargs -0 -r sed -i 's/\r$//'
chmod +x ./*.sh 2>/dev/null || true

# ---------------------------------------------------------------------
# 2. Khoi phuc cau hinh ve ban goc roi moi thay MSSV
# ---------------------------------------------------------------------
mkdir -p .mau/monitoring
for f in monitoring/prometheus.yml; do
  [ -f "$f" ] || continue
  if grep -q 'MSSV' "$f"; then
    cp -f "$f" ".mau/$f"
  elif [ -f ".mau/$f" ] && grep -q 'MSSV' ".mau/$f"; then
    cp -f ".mau/$f" "$f"
  fi
done
sed -i "s/MSSV/$MSSV/g" monitoring/prometheus.yml
echo "==> Da thay MSSV = $MSSV trong monitoring/"

# ---------------------------------------------------------------------
# 3. Mat khau -- DUNG BO GIONG HET BAI 7
# Phai giong het, neu khong MySQL da khoi tao voi mat khau cu se tu choi
# tai khoan moi, va toan bo du lieu WordPress cua bai 7 thanh vo dung.
# ---------------------------------------------------------------------
export MSSV
export WP_DB="wp_$MSSV"
export WP_USER="wp_$MSSV"
export WP_PASSWORD="WpMatKhau_${MSSV}_2026"
export MYSQL_ROOT_PASSWORD="RootMySQL_${MSSV}_2026"
export EXPORTER_USER="exporter_$MSSV"
export EXPORTER_PASSWORD="Exporter_${MSSV}_2026"
export GRAFANA_USER="admin"
export GRAFANA_PASSWORD="Grafana_${MSSV}_2026"
export BIND_ADDR
export HOST_UID="$(id -u)"
export HOST_GID="$(id -g)"

# Token Telegram giu nguyen neu .env cu da co, de chay lai script khong
# xoa mat thu sinh vien da dien.
TELEGRAM_TOKEN=""
TELEGRAM_CHAT=""
if [ -f .env ]; then
  TELEGRAM_TOKEN=$(grep -E '^TELEGRAM_TOKEN=' .env | cut -d= -f2- || true)
  TELEGRAM_CHAT=$(grep -E '^TELEGRAM_CHAT=' .env | cut -d= -f2- || true)
fi

printf '%s\n' \
  "# File nay do cai-dat.sh sinh ra. Sua tay se bi ghi de o lan chay sau." \
  "MSSV=$MSSV" \
  "WP_DB=$WP_DB" \
  "WP_USER=$WP_USER" \
  "WP_PASSWORD=$WP_PASSWORD" \
  "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
  "EXPORTER_USER=$EXPORTER_USER" \
  "EXPORTER_PASSWORD=$EXPORTER_PASSWORD" \
  "GRAFANA_USER=$GRAFANA_USER" \
  "GRAFANA_PASSWORD=$GRAFANA_PASSWORD" \
  "BIND_ADDR=$BIND_ADDR" \
  "HOST_UID=$HOST_UID" \
  "HOST_GID=$HOST_GID" \
  "TELEGRAM_TOKEN=$TELEGRAM_TOKEN" \
  "TELEGRAM_CHAT=$TELEGRAM_CHAT" > .env
echo "==> Da sinh .env  (BIND_ADDR=$BIND_ADDR)"

# my.cnf cho mysql-exporter -- xem ghi chu dai o bai 7 ve UID.
printf '%s\n' \
  "# File nay do cai-dat.sh sinh ra. KHONG commit len Git." \
  "[client]" \
  "user = $EXPORTER_USER" \
  "password = $EXPORTER_PASSWORD" \
  "host = mysql-db" \
  "port = 3306" > monitoring/my.cnf
chmod 600 monitoring/my.cnf
echo "==> Da sinh monitoring/my.cnf (UID $HOST_UID)"

# ---------------------------------------------------------------------
# 4. Sinh alertmanager.yml tu ban mau
# File ket qua co the chua token Telegram nen KHONG commit -- .gitignore
# da loai no ra. Ban mau thi commit.
# ---------------------------------------------------------------------
cp -f monitoring/alertmanager.mau.yml monitoring/alertmanager.yml
if [ "$TELEGRAM" -eq 1 ]; then
  if [ -z "$TELEGRAM_TOKEN" ] || [ -z "$TELEGRAM_CHAT" ]; then
    echo
    echo "!! --telegram nhung chua co token. Lam ba buoc sau roi chay lai:"
    echo "!!   1. Nhan tin cho @BotFather tren Telegram, go /newbot, lay token"
    echo "!!   2. Nhan tin cho bot vua tao mot cau bat ky"
    echo "!!   3. Mo https://api.telegram.org/bot<TOKEN>/getUpdates, lay chat id"
    echo "!! Roi dien hai dong nay vao file .env:"
    echo "!!   TELEGRAM_TOKEN=..."
    echo "!!   TELEGRAM_CHAT=..."
    echo "!! Bo qua Telegram, chi dung bo nhan canh bao noi bo."
    echo
  else
    # KHONG neo vao dau dong (^): cac dong nay co thut le truoc dau nhan.
    sed -i "s|#TELEGRAM#||" monitoring/alertmanager.yml
    sed -i "s|THAY_BOT_TOKEN|$TELEGRAM_TOKEN|; s|THAY_CHAT_ID|$TELEGRAM_CHAT|" \
      monitoring/alertmanager.yml
    echo "==> Da bat gui canh bao ve Telegram"
  fi
fi

# ---------------------------------------------------------------------
# 5. Kiem cu phap TRUOC khi khoi dong
# Mot dau cach sai trong rule la Prometheus khong khoi dong duoc, va luc
# do ca he giam sat chet chu khong chi tang canh bao.
# ---------------------------------------------------------------------
echo "==> Kiem cu phap cac file cau hinh"
if docker image inspect prom/prometheus:latest >/dev/null 2>&1; then
  docker run --rm -v "$PWD/monitoring:/m:ro" --entrypoint promtool \
    prom/prometheus:latest check rules /m/rules/alerts.yml \
    || { echo "LOI: rules/alerts.yml sai cu phap. Dung lai."; exit 1; }
else
  echo "    (chua co anh prometheus, se kiem lai sau khi tai xong)"
fi

# ---------------------------------------------------------------------
# 6. Kiem cong bi chiem boi nguoi ngoai
# ---------------------------------------------------------------------
for cong in 8080 9090 3000 3100 9093 5001; do
  for ai in $(docker ps --format '{{.Names}} {{.Ports}}' 2>/dev/null | grep ":$cong->" | awk '{print $1}'); do
    du_an=$(docker inspect -f '{{index .Config.Labels "com.docker.compose.project"}}' "$ai" 2>/dev/null || true)
    [ "$du_an" = "bai7-lab" ] && continue
    echo "LOI: cong $cong dang bi container \"$ai\" chiem (khong thuoc bai lab)."
    echo "     Dung no roi chay lai:  docker rm -f $ai"
    exit 1
  done
done

# ---------------------------------------------------------------------
# 7. Tai bon anh MOI (ba anh cu cua bai 7 da co san)
# ---------------------------------------------------------------------
echo "==> Tai cac anh Docker con thieu"
thieu=0
for anh in grafana/loki:latest grafana/promtail:latest \
           prom/alertmanager:latest python:3.12-alpine; do
  printf "    %-32s " "$anh"
  if docker image inspect "$anh" >/dev/null 2>&1; then
    echo "da co"
  elif docker pull -q "$anh" >/dev/null 2>&1; then
    echo "xong"
  else
    echo "LOI"
    thieu=1
  fi
done
[ "$thieu" -eq 1 ] && { echo "LOI: it nhat mot anh khong tai duoc. Kiem mang."; exit 1; }

# ---------------------------------------------------------------------
# 8. Dung stack -- KHONG "down", chi "up -d"
# Compose se tu nhan ra bay container cu van dung cau hinh va de yen,
# chi tao bon container moi. Du lieu Prometheus va Grafana nguyen ven.
# ---------------------------------------------------------------------
echo "==> Dung them tang log va canh bao"
docker compose up -d

# Nap lai cau hinh Prometheus ma khong khoi dong lai tien trinh.
echo "==> Nap lai cau hinh Prometheus"
sleep 3
docker compose exec -T prometheus \
  wget -q --post-data='' -O- http://localhost:9090/-/reload >/dev/null 2>&1 \
  && echo "    da nap lai" \
  || { echo "    khong goi duoc API, khoi dong lai prometheus"; docker compose restart prometheus >/dev/null; }

# ---------------------------------------------------------------------
# 9. Cho Loki nhan duoc dong log dau tien
# ---------------------------------------------------------------------
echo "==> Cho Loki nhan log (toi da 2 phut)"
# HOI LOKI TU TRONG CONTAINER PROMETHEUS, khong phai tu chinh container Loki.
# Anh grafana/loki duoc dung tren nen toi gian: KHONG co wget, khong co curl,
# khong co shell day du. "docker compose exec loki wget ..." luon that bai.
# Prometheus va Loki cung nam o monitor_net nen goi bang ten dich vu duoc.
#
# Va phai co "|| true": script chay voi "set -euo pipefail", nen mot duong
# ong that bai trong $( ) se lam CA SCRIPT THOAT ngay tai day, im lang,
# khong in them dong nao. Luc Loki chua san sang thi dung la no that bai.
ok=0
for i in $(seq 1 24); do
  n=$( { docker compose exec -T prometheus wget -qO- \
           'http://loki:3100/loki/api/v1/label/container/values' 2>/dev/null \
         | grep -o '"[a-z0-9-]\+"' | grep -cv '^"\(status\|success\|values\)"$' ; } || true )
  printf "\r    So container da co log trong Loki: %s  (%ds)" "${n:-0}" "$((i*5))"
  if [ "${n:-0}" -ge 3 ]; then ok=1; break; fi
  sleep 5
done
echo
[ "$ok" -eq 1 ] || echo "    (chua du -- xem ./kiem-tra.sh de biet ket qua)"

# ---------------------------------------------------------------------
# 10. Ghi lai phien ban that da dung
# ---------------------------------------------------------------------
{
  echo "# Phien ban that da dung, sinh luc: $(date '+%d/%m/%Y %H:%M:%S')"
  echo
  printf "%-24s %-22s %s\n" CONTAINER ANH MA-BAM
  for c in loki promtail alertmanager bao-dong; do
    anh=$(docker inspect -f '{{.Config.Image}}' "$c" 2>/dev/null || echo '-')
    bam=$(docker inspect -f '{{index .RepoDigests 0}}' "$anh" 2>/dev/null \
          | cut -d@ -f2 || echo '-')
    printf "%-24s %-22s %s\n" "$c" "$anh" "$bam"
  done
} > phien-ban-da-dung-bai8.txt
echo "==> Da ghi phien-ban-da-dung-bai8.txt"

IP=$(hostname -I 2>/dev/null | awk '{print $1}')
echo
echo "=================================================================="
echo " CAI DAT XONG"
echo "=================================================================="
docker compose ps --format 'table {{.Name}}\t{{.Status}}'
echo
if [ "$BIND_ADDR" = "0.0.0.0" ]; then
  echo " Grafana      : http://${IP:-<IP-may-ao>}:3000   ($GRAFANA_USER / $GRAFANA_PASSWORD)"
  echo " Prometheus   : http://${IP:-<IP-may-ao>}:9090"
  echo " Alertmanager : http://${IP:-<IP-may-ao>}:9093"
  echo " Bao dong     : http://${IP:-<IP-may-ao>}:5001"
else
  echo " Mo TRONG may ao:"
  echo "   Grafana      : http://localhost:3000   ($GRAFANA_USER / $GRAFANA_PASSWORD)"
  echo "   Prometheus   : http://localhost:9090   (muc Alerts)"
  echo "   Alertmanager : http://localhost:9093"
  echo "   Bao dong     : http://localhost:5001   <-- canh bao hien o day"
  echo
  echo " Tu may that, mo duong ham SSH:"
  echo "   ssh -L 3000:127.0.0.1:3000 -L 9090:127.0.0.1:9090 \\"
  echo "       -L 9093:127.0.0.1:9093 -L 5001:127.0.0.1:5001 \\"
  echo "       $(whoami)@${IP:-<IP-may-ao>}"
fi
echo
echo " Buoc tiep theo:"
echo "   ./kiem-tra.sh $MSSV          # kiem chung toan bo"
echo "   ./tao-loi.sh dung-exporter   # gay su co that de canh bao keu"

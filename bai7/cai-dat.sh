#!/usr/bin/env bash
# =====================================================================
# Bai lab 7 -- CAI DAT SACH, doc lap hoan toan voi cac bai lab truoc.
#
#   ./cai-dat.sh k23          # cai sach: xoa stack bai 7 cu roi dung lai
#   ./cai-dat.sh k23 --giu    # giu du lieu dang co, chi nap lai cau hinh
#
# Chay bao nhieu lan cung ra dung mot ket qua.
# =====================================================================
set -euo pipefail

MSSV="${1:?Cach dung: ./cai-dat.sh <MSSV>   (vi du: ./cai-dat.sh k23)}"
case "$MSSV" in --*) echo "LOI: tham so dau tien phai la MSSV, khong phai co."; exit 1;; esac
GIU=0
for t in "$@"; do [ "$t" = "--giu" ] && GIU=1; done
cd "$(dirname "$0")"

echo "=================================================================="
echo " BAI LAB 7 -- CAI DAT   (MSSV = $MSSV)"
echo "=================================================================="

# ---------------------------------------------------------------------
# 0. Doi hoi ve moi truong
# ---------------------------------------------------------------------
if ! docker info >/dev/null 2>&1; then
  echo "LOI: khong goi duoc Docker."
  echo "     Chua cai  -> chay:  ./cai-dat-docker.sh"
  echo "     Da cai roi -> nhom docker chua co hieu luc, go:  newgrp docker"
  exit 1
fi

drv=$(docker info --format '{{.Driver}}')
if [ "$drv" != "overlay2" ]; then
  echo "!! Trinh luu tru o dia dang la \"$drv\", khong phai overlay2."
  echo "!! cAdvisor se KHONG doc duoc chi so cua tung container, va bieu do"
  echo "!! \"CPU tung container\" o Buoc 12 se trong rong ma khong bao loi."
  echo "!! Xu ly: xem muc Su co trong tai lieu, roi chay lai script nay."
  echo
fi

# ---------------------------------------------------------------------
# 1. Chuan hoa xuong dong
# File di qua Windows mang ky tu CR o cuoi dong. Bash doc CR nhu mot
# phan cua gia tri, Docker Compose thi cat bo -- mot ky tu vo hinh la du
# gay "Access denied". Cat sach ngay tu dau.
# ---------------------------------------------------------------------
find . -type f \( -name '*.sh' -o -name '*.sql' -o -name '*.yml' \
     -o -name '*.cnf' -o -name '*.example' -o -name '.env' \) -print0 \
  | xargs -0 -r sed -i 's/\r$//'
chmod +x ./*.sh 2>/dev/null || true

# ---------------------------------------------------------------------
# 2. Khoi phuc file cau hinh ve ban goc roi moi thay MSSV
# Dung chinh chuoi "MSSV" lam dau nhan biet:
#   - File con chua chu MSSV -> ban goc (vua keo ve tu git). Cap nhat .mau/
#   - File khong con MSSV nhung .mau/ co -> da thay o lan truoc. Khoi phuc.
#   - Ca hai deu khong co -> khong co cho de thay. De yen.
# Nho quy tac dau, sau "git pull" ban moi duoc dung ngay, khong bi ban
# cu trong .mau/ de len.
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
# 3. Mat khau -- chi ton tai o DUNG MOT CHO
# Cac bien duoi day la nguon duy nhat. Tu chung ghi ra .env cho Compose,
# ghi ra my.cnf cho mysql-exporter, va cung chinh chung duoc truyen thang
# cho lenh mysql. Script KHONG "source .env", nen khong the co chuyen
# Compose va Bash doc ra hai chuoi khac nhau.
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

if [ "$GIU" -eq 1 ] && [ -f .env ]; then
  echo "==> --giu: dung lai .env dang co"
  set -a; . ./.env; set +a
else
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
    "GRAFANA_PASSWORD=$GRAFANA_PASSWORD" > .env
  echo "==> Da sinh .env"
fi

# my.cnf cho mysql-exporter -- sinh tu cung bo bien o tren.
# Tu ban 0.15.0 mysqld_exporter KHONG con doc DATA_SOURCE_NAME nua.
printf '%s\n' \
  "# File nay do cai-dat.sh sinh ra. KHONG commit len Git." \
  "[client]" \
  "user = $EXPORTER_USER" \
  "password = $EXPORTER_PASSWORD" \
  "host = mysql-db" \
  "port = 3306" > monitoring/my.cnf
chmod 600 monitoring/my.cnf
echo "==> Da sinh monitoring/my.cnf cho mysql-exporter"

# ---------------------------------------------------------------------
# 4. Don rieng stack bai lab 7
# ---------------------------------------------------------------------
if [ "$GIU" -eq 0 ]; then
  echo "==> Xoa stack bai lab 7 cu (neu co)"
  docker compose down -v --remove-orphans >/dev/null 2>&1 || true
  for c in wordpress mysql-db prometheus grafana node-exporter cadvisor mysql-exporter; do
    docker rm -f "$c" >/dev/null 2>&1 && echo "    - da xoa container con sot: $c" || true
  done
fi

for cong in 8080 9090 3000; do
  ai=$(docker ps --format '{{.Names}} {{.Ports}}' 2>/dev/null | grep ":$cong->" | awk '{print $1}' || true)
  if [ -n "$ai" ]; then
    echo "LOI: cong $cong dang bi container \"$ai\" chiem."
    echo "     Dung no roi chay lai:  docker rm -f $ai"
    exit 1
  fi
done

# ---------------------------------------------------------------------
# 5. Dung stack
# ---------------------------------------------------------------------
# Tai tung anh mot. Neu goi chung "docker compose up", loi "manifest
# unknown" khong noi ro anh nao hong -- rat mat cong tim.
echo "==> Tai bay anh Docker (lan dau khoang 1,5 GB, mat vai phut)"
thieu=0
for anh in $(docker compose config --images); do
  printf "    %-40s " "$anh"
  if docker image inspect "$anh" >/dev/null 2>&1; then
    echo "da co"
  elif docker pull -q "$anh" >/dev/null 2>&1; then
    echo "da tai ve"
  else
    echo "KHONG TAI DUOC"
    thieu=1
  fi
done
if [ "$thieu" -eq 1 ]; then
  echo
  echo "LOI: it nhat mot anh khong tai duoc."
  echo "     Kiem mang:  ping -c1 registry-1.docker.io"
  exit 1
fi

echo "==> Dung stack"
docker compose up -d

# ---------------------------------------------------------------------
# 6. Cho toi khi Prometheus THAY DU BON TARGET O TRANG THAI UP
# "container dang chay" chua du: Prometheus van song ngay ca khi moi
# target deu hong. Phep thu dung la hoi chinh Prometheus xem no dang
# thay gi.
# ---------------------------------------------------------------------
dem_up() {
  docker compose exec -T prometheus \
    wget -qO- 'http://localhost:9090/api/v1/targets?state=active' 2>/dev/null \
    | grep -o '"health":"up"' | wc -l
}

echo "==> Cho bon target len UP (toi da 4 phut)"
n=0
for i in $(seq 1 48); do
  n=$(dem_up 2>/dev/null || echo 0)
  printf "\r    Target UP: %s/4  (%ds)" "$n" "$((i*5))"
  [ "$n" -ge 4 ] && break
  sleep 5
done
echo

if [ "$n" -lt 4 ]; then
  echo
  echo "=================================================================="
  echo " CHUA DU BON TARGET -- thong tin de chan doan"
  echo "=================================================================="
  docker compose exec -T prometheus \
    wget -qO- 'http://localhost:9090/api/v1/targets?state=active' 2>/dev/null \
    | tr ',' '\n' | grep -E '"job"|"health"|lastError' | sed 's/^/   /' | head -40
  echo
  echo " Doc cot lastError de biet target nao hong va vi sao."
  echo " Nhat ky cua tung dich vu:  docker compose logs <ten-dich-vu>"
  echo "=================================================================="
fi

# ---------------------------------------------------------------------
# 7. Ghi lai PHIEN BAN THAT da dung
#
# docker-compose.yml dung the ":latest" de bai lab cai duoc ngay tren moi
# may. Nhung ":latest" hom nay va ":latest" thang sau co the la hai ban
# khac nhau -- nghia la he thong KHONG tai lap duoc.
#
# Cach xu ly dung: cai bang latest, roi GHI LAI dung ban minh da nhan,
# kem ca ma bam (digest). File nay dua vao Git. Khi can dung lai y het
# he thong cua hom nay -- vi du de dieu tra mot su co -- thi ghim theo
# ma bam trong file nay.
# ---------------------------------------------------------------------
{
  echo "# Phien ban that da dung, sinh luc: $(date '+%d/%m/%Y %H:%M:%S')"
  echo "# May: $(hostname)   MSSV: $MSSV"
  echo
  docker compose images --format table 2>/dev/null \
    || docker compose images 2>/dev/null
  echo
  echo "# Ma bam day du (dung de ghim tuyet doi):"
  for anh in $(docker compose config --images); do
    d=$(docker image inspect "$anh" --format '{{index .RepoDigests 0}}' 2>/dev/null)
    [ -n "$d" ] && echo "#   $d"
  done
} > phien-ban-da-dung.txt
echo "==> Da ghi phien-ban-da-dung.txt"

# ---------------------------------------------------------------------
# 8. Bao cao
# ---------------------------------------------------------------------
IP=$(hostname -I 2>/dev/null | awk '{print $1}')
echo
echo "=================================================================="
echo " CAI DAT XONG"
echo "=================================================================="
docker compose ps --format 'table {{.Name}}\t{{.Status}}\t{{.Ports}}'
cat <<HD

 WordPress  : http://${IP:-<IP-may-ao>}:8080

 Prometheus va Grafana CHI nghe tren 127.0.0.1 cua may ao -- dung y
 cua Moc 7. Tu may that, mo mot duong ham SSH roi truy cap qua localhost:

   ssh -L 9090:127.0.0.1:9090 -L 3000:127.0.0.1:3000 $(whoami)@${IP:-<IP-may-ao>}

 rồi mở trên máy thật:
   Prometheus : http://localhost:9090
   Grafana    : http://localhost:3000   ($GRAFANA_USER / $GRAFANA_PASSWORD)

 Buoc tiep theo:
   ./kiem-tra.sh $MSSV        # kiem chung toan bo
   ./tao-tai.sh 120           # sinh tai gia 120 giay de thay dinh CPU
HD

#!/usr/bin/env bash
# =====================================================================
# Bai lab 7 -- BUOC 0: CAI DOCKER TREN MAY AO TRANG
#
#   ./cai-dat-docker.sh
#
# Chay MOT LAN tren may ao Ubuntu vua cai xong. Neu may da co Docker
# tu bai lab truoc, script van chay duoc: no chi bo sung nhung gi con
# thieu va sua lai cau hinh o dia (xem muc 4 duoi day).
#
# Sau khi chay xong PHAI DANG XUAT RA VAO LAI, hoac go: newgrp docker
# =====================================================================
set -euo pipefail

echo "=================================================================="
echo " BAI LAB 7 -- CAI DAT DOCKER"
echo "=================================================================="

if [ "$(id -u)" -eq 0 ]; then
  echo "LOI: dung chay bang root. Chay bang tai khoan thuong, script tu goi sudo."
  exit 1
fi

# ---------------------------------------------------------------------
# 1. Go cac ban Docker cu do Ubuntu dong goi
# Ubuntu co san goi ten "docker.io" va "docker-compose" -- ban cu, va
# QUAN TRONG HON: chung khong di kem "docker compose" (v2, viet lien).
# Ca bai lab dung cu phap v2, nen phai cai tu kho chinh thuc cua Docker.
# ---------------------------------------------------------------------
echo "==> 1. Go cac goi Docker cu cua Ubuntu (neu co)"
for goi in docker.io docker-doc docker-compose docker-compose-v2 \
           podman-docker containerd runc; do
  sudo apt-get remove -y "$goi" >/dev/null 2>&1 || true
done

# ---------------------------------------------------------------------
# 2. Them kho chinh thuc cua Docker
# ---------------------------------------------------------------------
echo "==> 2. Them kho phan mem chinh thuc cua Docker"
sudo apt-get update -qq
sudo apt-get install -y -qq ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.asc ]; then
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
       -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
fi

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update -qq

# ---------------------------------------------------------------------
# 3. Cai Docker Engine va plugin Compose
# ---------------------------------------------------------------------
echo "==> 3. Cai Docker Engine + docker compose plugin"
sudo apt-get install -y -qq \
     docker-ce docker-ce-cli containerd.io \
     docker-buildx-plugin docker-compose-plugin

# ---------------------------------------------------------------------
# 4. Chon trinh luu tru o dia: overlay2
#
# DAY LA BUOC RIENG CUA BAI LAB 7, khong co trong cac bai truoc.
#
# Tu Docker 29, mot so ban cai bat "containerd snapshotter" va dung
# trinh luu tru ten "overlayfs" (khac "overlay2"). Docker chay binh
# thuong, moi thu deu on -- TRU cAdvisor: no doi thu muc
#   /var/lib/docker/image/overlay2/layerdb/...
# de tra ID container ra ten container. Voi "overlayfs" thu muc do
# khong ton tai, nen cAdvisor chi bao duoc chi so cua cgroup goc, con
# bieu do "CPU tung container" thi TRONG RONG -- ma khong mot dong log
# nao bao loi.
#
# Vi day la may ao moi, sua ngay bay gio la re nhat: chua co du lieu
# gi de mat. Doi den luc phat hien bieu do trong thi phai xoa sach
# /var/lib/docker moi doi duoc.
# ---------------------------------------------------------------------
echo "==> 4. Dat trinh luu tru o dia = overlay2 (cAdvisor doi hoi)"
sudo mkdir -p /etc/docker
if [ -f /etc/docker/daemon.json ] && ! grep -q '"storage-driver"' /etc/docker/daemon.json; then
  echo "    CANH BAO: /etc/docker/daemon.json da ton tai va khong co"
  echo "              storage-driver. Script KHONG ghi de -- sua tay:"
  echo "              them  \"storage-driver\": \"overlay2\"  vao file do."
else
  printf '%s\n' \
    '{' \
    '  "storage-driver": "overlay2",' \
    '  "features": { "containerd-snapshotter": false },' \
    '  "log-driver": "json-file",' \
    '  "log-opts": { "max-size": "10m", "max-file": "3" }' \
    '}' | sudo tee /etc/docker/daemon.json >/dev/null
  echo "    da ghi /etc/docker/daemon.json"
fi

# log-opts o tren cung la mot muc dang doc: mac dinh Docker ghi nhat ky
# KHONG GIOI HAN dung luong. Mot container noi nhieu co the an het o dia
# may ao sau vai ngay. Day la nguyen nhan pho bien nhat cua "dia day"
# tren may chu chay Docker, va la noi dung cua Bai lab 8.

# ---------------------------------------------------------------------
# 5. Cho tai khoan hien tai dung docker khong can sudo
# ---------------------------------------------------------------------
echo "==> 5. Them $(whoami) vao nhom docker"
sudo groupadd -f docker
sudo usermod -aG docker "$(whoami)"

echo "==> 6. Bat va khoi dong lai dich vu"
sudo systemctl enable --now docker >/dev/null 2>&1 || true
sudo systemctl restart docker
sleep 3

# ---------------------------------------------------------------------
# 7. Bao cao
# ---------------------------------------------------------------------
echo
echo "=================================================================="
echo " KIEM CHUNG"
echo "=================================================================="
sudo docker version --format '  Engine  : {{.Server.Version}}'
sudo docker compose version --short | sed 's/^/  Compose : /'
sudo docker info --format '  O dia   : {{.Driver}}'
sudo docker info --format '  Cgroup  : v{{.CgroupVersion}}'

drv=$(sudo docker info --format '{{.Driver}}')
if [ "$drv" != "overlay2" ]; then
  echo
  echo "  !! Trinh luu tru dang la \"$drv\", KHONG phai overlay2."
  echo "  !! Bieu do \"CPU tung container\" se trong rong o Buoc 12."
  echo "  !! Xu ly: xem muc Su co trong tai lieu."
fi

cat <<'HD'

==================================================================
 CON MOT VIEC PHAI LAM BANG TAY
==================================================================
 Tai khoan cua ban vua duoc them vao nhom "docker", nhung phien dang
 nhap hien tai chua biet dieu do. Chon mot trong hai:

     newgrp docker          # ap dung ngay cho cua so terminal nay
     exit  roi dang nhap lai   # ap dung cho moi cua so

 Kiem tra da xong bang lenh SAU DAY -- khong co "sudo":

     docker run --rm hello-world

 Thay dong "Hello from Docker!" la sang duoc Buoc tiep theo.
HD

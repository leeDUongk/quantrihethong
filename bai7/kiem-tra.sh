#!/usr/bin/env bash
# Bai lab 7 -- kiem chung toan bo cai dat.
#   ./kiem-tra.sh k23
set -u
MSSV="${1:-k23}"
cd "$(dirname "$0")"
[ -f .env ] && { set -a; . ./.env; set +a; }

pq() { docker compose exec -T prometheus wget -qO- "http://localhost:9090/api/v1/$1" 2>/dev/null; }

echo "=== 1. Bay container phai deu dang chay ==="
docker compose ps --format 'table {{.Name}}\t{{.Status}}'

echo
echo "=== 2. Ba mang tach bach ==="
printf "  mysql-exporter o ca hai mang: "
# KHONG dung "docker exec mysql-exporter getent ...": anh prom/mysqld-exporter
# duoc dung tren nen toi gian, KHONG co getent lan ping lan shell day du, nen
# lenh do luon that bai va bao SAI oan. Hoi thang Docker xem container dang
# gan vao nhung mang nao moi la cach dung.
mang=$(docker inspect mysql-exporter \
       --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}' 2>/dev/null || true)
if echo "$mang" | grep -q "db_net_${MSSV}" && echo "$mang" | grep -q "monitor_net_${MSSV}"; then
  echo "co (DUNG -- $mang)"
else
  echo "KHONG (SAI -- dang o: ${mang:-khong doc duoc})"
fi
printf "  prometheus     -> mysql-db  : "
docker exec prometheus getent hosts mysql-db >/dev/null 2>&1 \
  && echo "GOI DUOC (SAI -- he giam sat khong duoc cham vao CSDL)" \
  || echo "khong goi duoc (DUNG)"
printf "  mysql-db       -> Internet  : "
docker exec mysql-db timeout 5 bash -c "cat < /dev/null > /dev/tcp/8.8.8.8/53" 2>/dev/null \
  && echo "RA DUOC INTERNET (SAI -- kiem tra internal:true)" || echo "khong ra duoc (DUNG)"

echo
echo "=== 3. Bon target cua Prometheus ==="
pq 'targets?state=active' \
  | tr '}' '\n' | grep -o '"job":"[^"]*"\|"health":"[^"]*"' \
  | paste - - 2>/dev/null | sed 's/"job":"/  /; s/"//g; s/health:/-> /' \
  || echo "  (khong doc duoc -- Prometheus chua san sang?)"
so_up=$(pq 'targets?state=active' | grep -o '"health":"up"' | wc -l)
echo "  Tong so UP: $so_up / 4"
[ "$so_up" -ge 4 ] && echo "  (DUNG)" || echo "  (SAI -- xem lastError o Buoc 10)"

echo
echo "=== 4. Co du lieu that hay khong ==="
kiem() {
  v=$(pq "query?query=$2" | grep -o '"value":\[[^]]*\]' | head -1)
  if [ -n "$v" ]; then echo "  $1: co du lieu (DUNG)"; else echo "  $1: KHONG co du lieu (SAI)"; fi
}
kiem "CPU may chu      " 'node_cpu_seconds_total'
kiem "RAM may chu      " 'node_memory_MemAvailable_bytes'
kiem "CPU tung container" 'container_cpu_usage_seconds_total%7Bname!%3D%22%22%7D'
kiem "MySQL            " 'mysql_up'

echo
echo "=== 5. cAdvisor co tach duoc TUNG container khong ==="
# Prometheus tra ve  "value":[1757581234.567,"7"]  -- gia tri la phan tu THU HAI
# va nam TRONG dau nhay. Cat tu dau phay cuoi den het la lay dung so.
so_ct=$(pq 'query?query=count(count%20by%20(name)%20(container_cpu_usage_seconds_total%7Bname!%3D%22%22%7D))' \
        | grep -o '"value":\[[^]]*\]' | head -1 | sed 's/.*,"//; s/".*//')
case "$so_ct" in (*[!0-9]*|'') so_ct=0 ;; esac
echo "  So container co ten ma cAdvisor thay: $so_ct"
if [ "$so_ct" -ge 5 ]; then
  echo "  (DUNG)"
else
  echo "  (SAI) Lan theo thu tu nay, dung lai o buoc dau tien sai:"
  echo "    1) cAdvisor co tu sinh nhan ten khong:"
  echo "         docker exec cadvisor wget -qO- http://127.0.0.1:8080/metrics | grep -c 'name=\"'"
  echo "       Ra 0  -> loi o cAdvisor. Thuong gap nhat: trinh luu tru o dia"
  echo "       khong phai overlay2 (kiem: docker info --format '{{.Driver}}'),"
  echo "       hoac thieu quyen  privileged / /var/run / /sys / /var/lib/docker."
  echo "       Ra vai tram -> cAdvisor binh thuong, sang buoc 2."
  echo "    2) Prometheus co thu duoc tu cAdvisor khong: mo muc 3 o tren, xem"
  echo "       target 'cadvisor' co UP khong."
fi

echo
echo "=== 6. Grafana da nap san nguon du lieu va dashboard chua ==="
printf "  Nguon du lieu : "
docker compose exec -T grafana \
  wget -qO- --header="Accept: application/json" \
  "http://${GRAFANA_USER:-admin}:${GRAFANA_PASSWORD:-admin}@localhost:3000/api/datasources" 2>/dev/null \
  | grep -q '"type":"prometheus"' && echo "co (DUNG)" || echo "KHONG co (SAI)"
printf "  Dashboard     : "
docker compose exec -T grafana \
  wget -qO- --header="Accept: application/json" \
  "http://${GRAFANA_USER:-admin}:${GRAFANA_PASSWORD:-admin}@localhost:3000/api/search?query=Tong%20quan" 2>/dev/null \
  | grep -q 'bai7-tong-quan' && echo "co (DUNG)" || echo "KHONG co (SAI)"

echo
echo "=== 7. Prometheus va Grafana nghe o dau ==="
if [ "${BIND_ADDR:-127.0.0.1}" = "0.0.0.0" ]; then
  echo "  Dang o che do --mo-lan: hai dich vu PHO RA MANG."
  echo "  Tien cho buoi hoc, nhung VI PHAM tieu chi Moc 7 cua du an."
  echo "  Truoc khi nop bai du an, chay lai KHONG co co --mo-lan."
else
  for c in 9090 3000; do
    printf "  Cong %s : " "$c"
    if docker ps --format '{{.Ports}}' | grep -q "0.0.0.0:$c->"; then
      echo "PHO RA 0.0.0.0 (SAI -- vi pham tieu chi Moc 7)"
    else
      echo "chi nghe 127.0.0.1 (DUNG)"
    fi
  done
fi

echo
echo "Xong. Doc ky cac dong (SAI) neu co."

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
printf "  mysql-exporter -> mysql-db  : "
docker exec mysql-exporter getent hosts mysql-db >/dev/null 2>&1 \
  && echo "goi duoc (DUNG -- no nam o ca hai mang)" || echo "KHONG goi duoc (SAI)"
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
so_ct=$(pq 'query?query=count(count%20by%20(name)%20(container_cpu_usage_seconds_total%7Bname!%3D%22%22%7D))' \
        | grep -o '"value":\[[^]]*\]' | grep -o '"[0-9]*"$' | tr -d '"')
echo "  So container co ten ma cAdvisor thay: ${so_ct:-0}"
if [ "${so_ct:-0}" -ge 5 ]; then
  echo "  (DUNG)"
else
  echo "  (SAI -- gan nhu chac chan do trinh luu tru o dia khong phai overlay2)"
  echo "         Kiem bang:  docker info --format '{{.Driver}}'"
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
echo "=== 7. Prometheus va Grafana KHONG duoc pho ra ngoai ==="
for c in 9090 3000; do
  printf "  Cong %s : " "$c"
  if docker ps --format '{{.Ports}}' | grep -q "0.0.0.0:$c->"; then
    echo "PHO RA 0.0.0.0 (SAI -- vi pham tieu chi Moc 7)"
  else
    echo "chi nghe 127.0.0.1 (DUNG)"
  fi
done

echo
echo "Xong. Doc ky cac dong (SAI) neu co."

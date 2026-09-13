#!/usr/bin/env bash
# Bai lab 8 -- kiem chung tang log va canh bao.
#   ./kiem-tra.sh k23
set -u
MSSV="${1:-k23}"
cd "$(dirname "$0")"
[ -f .env ] && { set -a; . ./.env; set +a; }

pq()  { docker compose exec -T prometheus   wget -qO- "http://localhost:9090/api/v1/$1" 2>/dev/null; }
lq()  { docker compose exec -T loki         wget -qO- "http://localhost:3100/$1"        2>/dev/null; }
amq() { docker compose exec -T alertmanager wget -qO- "http://localhost:9093/api/v2/$1" 2>/dev/null; }

echo "=== 1. Muoi mot container phai deu dang chay ==="
docker compose ps --format 'table {{.Name}}\t{{.Status}}'
so=$(docker compose ps --format '{{.Name}}' 2>/dev/null | wc -l)
echo "  Tong: $so / 11"
[ "$so" -ge 11 ] && echo "  (DUNG)" || echo "  (SAI -- thieu container, xem cot STATUS o tren)"

echo
echo "=== 2. Sau target cua Prometheus ==="
pq 'targets?state=active' | python3 -c '
import json, sys
try:
    ds = json.load(sys.stdin)["data"]["activeTargets"]
except Exception:
    print("  (khong doc duoc -- Prometheus chua san sang?)"); raise SystemExit
for t in sorted(ds, key=lambda x: x["scrapePool"]):
    print("  %-16s %-5s %s" % (t["scrapePool"], t["health"], t.get("lastError", "")))
' 2>/dev/null || echo "  (khong doc duoc)"
so_up=$(pq 'targets?state=active' | grep -o '"health":"up"' | wc -l)
echo "  Tong so UP: $so_up / 6"
[ "$so_up" -ge 6 ] && echo "  (DUNG)" || echo "  (SAI)"

echo
echo "=== 3. Loki co nhan duoc log khong ==="
printf "  Loki san sang        : "
lq 'ready' | grep -q 'ready' && echo "co (DUNG)" || echo "CHUA (SAI -- docker compose logs loki)"
ct=$(lq 'loki/api/v1/label/container/values' | grep -o '"[a-z0-9-]\+"' | tr -d '"' | grep -v '^values$\|^status$\|^success$' | sort -u)
n_ct=$(echo "$ct" | grep -c . || true)
echo "  So container co log  : $n_ct"
echo "$ct" | sed 's/^/      - /'
[ "${n_ct:-0}" -ge 5 ] && echo "  (DUNG)" || echo "  (SAI -- Promtail chua day duoc log, xem: docker compose logs promtail)"

printf "  Nhan 'muc' da tach   : "
lq 'loki/api/v1/label/muc/values' | grep -q 'error\|warn' \
  && echo "co (DUNG)" \
  || echo "chua co (chua sao -- chi co khi da xuat hien dong log co tu error/warn)"

echo
echo "=== 4. Alerting rule da nap duoc chua ==="
pq 'rules' | python3 -c '
import json, sys
try:
    gs = json.load(sys.stdin)["data"]["groups"]
except Exception:
    print("  (khong doc duoc)"); raise SystemExit
tong = 0
for g in gs:
    rs = [r for r in g.get("rules", []) if r.get("type") == "alerting"]
    tong += len(rs)
    print("  nhom %-12s %d rule" % (g["name"], len(rs)))
    for r in rs:
        tt = r.get("state", "?")
        dau = "  <-- DANG KEU" if tt == "firing" else ("  <-- dang cho" if tt == "pending" else "")
        print("      %-28s %s%s" % (r["name"], tt, dau))
print("  Tong so rule: %d" % tong)
print("  (DUNG)" if tong >= 8 else "  (SAI -- kiem rule_files trong prometheus.yml)")
' 2>/dev/null || echo "  (khong doc duoc)"

echo
echo "=== 5. Prometheus co ket noi duoc toi Alertmanager khong ==="
n_am=$(pq 'alertmanagers' | grep -o '"url":"[^"]*"' | wc -l)
echo "  So Alertmanager dang hoat dong: $n_am"
[ "${n_am:-0}" -ge 1 ] && echo "  (DUNG)" || echo "  (SAI -- kiem khoi 'alerting' trong prometheus.yml)"

echo
echo "=== 6. Alertmanager va bo nhan canh bao ==="
printf "  Alertmanager tra loi : "
amq 'status' | grep -q '"cluster"\|"versionInfo"' && echo "co (DUNG)" || echo "KHONG (SAI)"
printf "  So canh bao dang giu : "
amq 'alerts' | grep -o '"fingerprint"' | wc -l
printf "  Bo nhan canh bao     : "
docker compose exec -T alertmanager wget -qO- http://bao-dong:5001/khoe 2>/dev/null \
  | grep -q ok && echo "song (DUNG)" || echo "KHONG goi duoc (SAI)"

echo
echo "=== 7. Grafana da nap nguon du lieu Loki chua ==="
ds=$(docker compose exec -T grafana wget -qO- --header="Accept: application/json" \
     "http://${GRAFANA_USER:-admin}:${GRAFANA_PASSWORD:-admin}@localhost:3000/api/datasources" 2>/dev/null)
printf "  Nguon Prometheus : "; echo "$ds" | grep -q '"type":"prometheus"' && echo "co (DUNG)" || echo "KHONG (SAI)"
printf "  Nguon Loki       : "; echo "$ds" | grep -q '"type":"loki"'       && echo "co (DUNG)" || echo "KHONG (SAI)"
printf "  Dashboard bai 8  : "
docker compose exec -T grafana wget -qO- --header="Accept: application/json" \
  "http://${GRAFANA_USER:-admin}:${GRAFANA_PASSWORD:-admin}@localhost:3000/api/search?query=Log" 2>/dev/null \
  | grep -q 'bai8-log-canh-bao' && echo "co (DUNG)" || echo "KHONG (SAI)"

echo
echo "=== 8. Du lieu bai 7 con nguyen khong ==="
# Day la phep thu quan trong nhat cua viec ke thua: neu volume bi thay
# the, Prometheus se khong con du lieu cu va Moc 7 mat chuoi 24 gio.
tuoi=$(pq 'query?query=time()-process_start_time_seconds%7Bjob%3D%22prometheus%22%7D' \
       | grep -o '"value":\[[^]]*\]' | head -1 | sed 's/.*,"//; s/\..*//')
cu=$(pq 'query?query=count_over_time(up%5B24h%5D)' \
     | grep -o '"value":\[[^]]*\]' | head -1 | sed 's/.*,"//; s/".*//')
echo "  Prometheus chay lien tuc: ${tuoi:-?} giay"
echo "  So diem do trong 24h    : ${cu:-?}"
[ "${cu:-0}" -gt 100 ] 2>/dev/null \
  && echo "  (DUNG -- du lieu cu con nguyen)" \
  || echo "  (chua du -- binh thuong neu bai 7 vua dung xong)"

echo
echo "=== 9. Cong nghe o dau ==="
for c in 9090 3000 3100 9093 5001; do
  d=$(docker compose ps --format '{{.Ports}}' 2>/dev/null | tr ',' '\n' | grep ":$c->" | head -1)
  printf "  Cong %-5s : " "$c"
  case "$d" in
    *0.0.0.0*) echo "PHO RA MANG (SAI voi Moc 7 -- chay lai khong co --mo-lan)";;
    *127.0.0.1*) echo "chi nghe 127.0.0.1 (DUNG)";;
    *) echo "khong pho ra ngoai";;
  esac
done

echo
echo "Xong. Doc ky cac dong (SAI) neu co."
echo "Buoc tiep: ./tao-loi.sh dung-exporter   de xem canh bao keu that."

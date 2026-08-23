#!/usr/bin/env bash
# Chay toan bo lenh kiem chung cua muc 5.6 va 6.5.
# Cach dung:  ./kiem-tra.sh k23
MSSV="${1:-k23}"

echo "== 1. Container nam trong npm_network =="
docker network inspect npm_network \
  --format '{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null || echo "  network npm_network chua ton tai"

echo
echo "== 2. NPM co goi duoc tung backend bang ten container khong =="
for t in static-site php-web wp-app wp-phpmyadmin; do
  printf "  %-16s " "$t"
  docker exec nginx-proxy-manager \
    curl -s -o /dev/null -m 5 -w "%{http_code}\n" "http://$t:80" 2>/dev/null || echo "KHONG GOI DUOC"
done

echo
echo "== 3. Proxy phan luong theo Host header =="
for d in static app blog db; do
  printf "  %-22s " "$d.$MSSV.lab"
  curl -s -o /dev/null -m 5 -w "%{http_code}\n" -H "Host: $d.$MSSV.lab" http://127.0.0.1/
done

echo
echo "== 4. Ba cong cua may ao =="
sudo ss -ltnp 2>/dev/null | grep -E ':80 |:443 |:81 ' || echo "  khong thay cong nao dang lang nghe"

echo
echo "== 5. Log NPM (20 dong cuoi) =="
docker logs --tail 20 nginx-proxy-manager 2>&1 | grep -i "emerg\|error" || echo "  khong co dong loi"

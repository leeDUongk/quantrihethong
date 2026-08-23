#!/usr/bin/env bash
# Sinh chung chi tu ky co truong SAN phu ca 5 ten mien cua bai lab.
# Cach dung:  ./tao-chung-chi.sh k23
set -e
MSSV="${1:?Cach dung: ./tao-chung-chi.sh <MSSV>}"
OUT="$(dirname "$0")/certs"
mkdir -p "$OUT"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$OUT/$MSSV.key" -out "$OUT/$MSSV.crt" \
  -subj "/C=VN/ST=Thai Nguyen/O=ICTU/CN=$MSSV.lab" \
  -addext "subjectAltName=DNS:static.$MSSV.lab,DNS:app.$MSSV.lab,DNS:blog.$MSSV.lab,DNS:db.$MSSV.lab,DNS:npm.$MSSV.lab"

echo
echo "Da tao: $OUT/$MSSV.crt va $OUT/$MSSV.key"
openssl x509 -in "$OUT/$MSSV.crt" -noout -text | grep -A1 "Subject Alternative Name"
echo
echo "Nap vao NPM: SSL Certificates -> Add SSL Certificate -> Custom"

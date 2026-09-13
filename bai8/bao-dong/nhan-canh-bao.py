#!/usr/bin/env python3
# =====================================================================
# Bai lab 8 -- Bo nhan canh bao noi bo
#
# VI SAO CAN CAI NAY. Giao trinh huong dan gui canh bao qua Gmail. Trong
# phong may cua truong, cach do gan nhu chac chan that bai: Gmail doi
# "App Password" (ma tai khoan phai bat xac thuc hai buoc moi tao duoc),
# va cong 587 di ra ngoai thuong bi chan. Sinh vien se cau hinh dung het
# ma khong bao gio nhan duoc mail, roi khong biet sai o dau.
#
# Chuong trinh nay nhan webhook tu Alertmanager va lam hai viec:
#   1. IN RA dong ra chuan. Promtail dang doc log cua moi container, nen
#      moi canh bao cung chay thang vao Loki -- tra cuu duoc bang LogQL
#      cung khung thoi gian voi bieu do. Vong tron khep kin.
#   2. Giu lai 200 canh bao gan nhat va hien o http://127.0.0.1:5001
#
# Chi dung thu vien co san trong Python, khong cai them goi nao -- de
# bai lab con chay duoc sau nhieu nam.
# =====================================================================

import html
import json
import os
from collections import deque
from datetime import datetime, timezone, timedelta
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

CONG = int(os.environ.get("CONG", "5001"))
GIO_VN = timezone(timedelta(hours=7))
LICH_SU = deque(maxlen=200)

TRANG = """<!doctype html><html lang="vi"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="refresh" content="10">
<title>Bao dong -- Bai lab 8</title>
<style>
 :root{{color-scheme:light dark}}
 body{{font-family:system-ui,-apple-system,Segoe UI,sans-serif;margin:0;
      background:#0f1319;color:#e6e9ef}}
 header{{padding:18px 24px;background:#161b25;border-bottom:1px solid #262d3a}}
 h1{{margin:0;font-size:19px}}
 .phu{{color:#8b94a7;font-size:13px;margin-top:4px}}
 table{{width:100%;border-collapse:collapse;font-size:13.5px}}
 th{{text-align:left;padding:9px 24px;color:#8b94a7;font-weight:600;
     border-bottom:1px solid #262d3a;background:#131824}}
 td{{padding:9px 24px;border-bottom:1px solid #1c2230;vertical-align:top}}
 .critical{{color:#ff6b6b;font-weight:700}}
 .warning{{color:#ffc107;font-weight:700}}
 .firing{{color:#ff6b6b}} .resolved{{color:#4ade80}}
 code{{background:#1c2230;padding:1px 5px;border-radius:3px;font-size:12.5px}}
 .rong{{padding:40px 24px;color:#8b94a7}}
</style></head><body>
<header><h1>Bao dong -- Bai lab 8</h1>
<div class="phu">Da nhan {tong} canh bao &middot; trang tu lam moi 10 giay
&middot; Alertmanager: <code>http://127.0.0.1:9093</code></div></header>
{than}
</body></html>"""


def dung_trang():
    if not LICH_SU:
        than = ('<div class="rong">Chua nhan canh bao nao.<br><br>'
                'Chay <code>./tao-loi.sh dung-wordpress</code> de thu, '
                'roi doi khoang mot phut.</div>')
    else:
        hang = []
        for m in reversed(LICH_SU):
            hang.append(
                "<tr><td>{luc}</td>"
                "<td><strong>{ten}</strong><div class='phu'>{mota}</div></td>"
                "<td class='{muc}'>{muc}</td>"
                "<td class='{tt}'>{tt}</td></tr>".format(**m))
        than = ("<table><tr><th>Luc</th><th>Canh bao</th>"
                "<th>Muc</th><th>Trang thai</th></tr>"
                + "".join(hang) + "</table>")
    return TRANG.format(tong=len(LICH_SU), than=than)


def ghi_nhan(goi):
    """Doc mot goi webhook cua Alertmanager va luu lai tung canh bao."""
    for a in goi.get("alerts", []):
        nhan = a.get("labels", {})
        chu = a.get("annotations", {})
        m = {
            "luc": datetime.now(GIO_VN).strftime("%H:%M:%S %d/%m"),
            "ten": html.escape(nhan.get("alertname", "(khong ten)")),
            "muc": html.escape(nhan.get("severity", "khong-ro")),
            "tt": html.escape(a.get("status", "?")),
            "mota": html.escape(chu.get("description") or chu.get("summary") or ""),
        }
        LICH_SU.append(m)
        # Dong nay la thu Promtail se day vao Loki. Co chu "ALERT" o dau
        # de truy van {container="bao-dong"} |= "ALERT" bat duoc ngay.
        print("ALERT status={tt} severity={muc} alertname={ten} :: {mota}"
              .format(**m), flush=True)


class Xu(BaseHTTPRequestHandler):
    # Tat log truy cap mac dinh cua thu vien -- no in moi request thanh
    # mot dong rac, lam nhieu log that.
    def log_message(self, *a):
        pass

    def _tra(self, ma, kieu, noi_dung):
        b = noi_dung.encode("utf-8")
        self.send_response(ma)
        self.send_header("Content-Type", kieu + "; charset=utf-8")
        self.send_header("Content-Length", str(len(b)))
        self.end_headers()
        self.wfile.write(b)

    def do_GET(self):
        if self.path.startswith("/khoe"):
            self._tra(200, "text/plain", "ok")
        elif self.path.startswith("/json"):
            self._tra(200, "application/json",
                      json.dumps(list(LICH_SU), ensure_ascii=False))
        else:
            self._tra(200, "text/html", dung_trang())

    def do_POST(self):
        n = int(self.headers.get("Content-Length", 0))
        tho = self.rfile.read(n) if n else b"{}"
        try:
            ghi_nhan(json.loads(tho.decode("utf-8")))
        except Exception as e:
            print("LOI doc goi webhook:", e, flush=True)
            self._tra(400, "text/plain", "goi khong hop le")
            return
        self._tra(200, "text/plain", "da nhan")


if __name__ == "__main__":
    print("bao-dong: dang nghe tren cong", CONG, flush=True)
    ThreadingHTTPServer(("0.0.0.0", CONG), Xu).serve_forever()

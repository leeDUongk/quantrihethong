<?php
// Ung dung PHP toi gian -- dung de co mot backend "binh thuong" sau proxy.
// Thay MSSV bang ma so cua minh.
$mssv = 'MSSV';
?>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <title>Ung dung PHP - <?= htmlspecialchars($mssv) ?></title>
  <style>
    body{font-family:system-ui,sans-serif;max-width:640px;margin:60px auto;color:#1c2024;line-height:1.6}
    table{border-collapse:collapse;width:100%;margin-top:18px}
    td,th{border:1px solid #d4d8dd;padding:8px 10px;text-align:left}
    th{background:#f1f3f5}
    code{background:#f1f3f5;padding:2px 6px;border-radius:4px}
  </style>
</head>
<body>
  <h1>Ung dung PHP cua <?= htmlspecialchars($mssv) ?></h1>
  <p>Trang nay chay trong container <code>php-web</code>, khong khai bao <code>ports</code>.
     Neu ban doc duoc no qua ten mien thi Reverse Proxy dang hoat dong.</p>

  <table>
    <tr><th>Thong tin</th><th>Gia tri</th></tr>
    <tr><td>Ten container</td><td><code><?= htmlspecialchars(gethostname()) ?></code></td></tr>
    <tr><td>Host header proxy chuyen sang</td><td><code><?= htmlspecialchars($_SERVER['HTTP_HOST'] ?? '-') ?></code></td></tr>
    <tr><td>X-Forwarded-Proto</td><td><code><?= htmlspecialchars($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '(khong co)') ?></code></td></tr>
    <tr><td>X-Real-IP (IP that cua ban)</td><td><code><?= htmlspecialchars($_SERVER['HTTP_X_REAL_IP'] ?? '(khong co)') ?></code></td></tr>
    <tr><td>REMOTE_ADDR (proxy nhin thay)</td><td><code><?= htmlspecialchars($_SERVER['REMOTE_ADDR'] ?? '-') ?></code></td></tr>
    <tr><td>Thoi diem</td><td><?= date('H:i:s d/m/Y') ?></td></tr>
  </table>

  <p style="margin-top:18px;font-size:14px;color:#6b7280">
    Bang tren la cong cu chan doan: no cho thay <b>chinh xac cac header ma proxy gan them</b>.
    So sanh <code>X-Real-IP</code> voi <code>REMOTE_ADDR</code> de hieu vi sao backend can header nay
    moi biet duoc IP that cua nguoi dung (muc 6.3).
  </p>
</body>
</html>

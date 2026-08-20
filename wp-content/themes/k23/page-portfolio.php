<?php
/**
 * Template Name: Portfolio DevOps
 *
 * Trang giao dien doc lap. KHONG dung header.php va footer.php cua theme,
 * de giao dien nay khong anh huong toi trang chu.
 *
 * Cac "don bay demo" duoc giu nguyen:
 *   - K23_VERSION      (khai bao trong functions.php)
 *   - COMMIT.txt       (do vm/capnhat.sh ghi ra sau moi lan git pull)
 *   - gethostname()    (chung minh trang dang chay tren may ao)
 *   - thoi gian tai    (do bang timer cua WordPress)
 */

$k23_bat_dau = microtime(true);

$k23_commit = trim(@file_get_contents(get_template_directory() . '/COMMIT.txt'));
if ($k23_commit === '') {
    $k23_commit = 'chua co commit';
}
$k23_ver  = defined('K23_VERSION') ? K23_VERSION : '1.0';
$k23_repo = defined('K23_REPO') ? K23_REPO : 'github.com/<tai-khoan-github>/quantrihethong-<MSSV>';

/* ---- Noi dung dang du lieu, de sua ma khong dung vao phan giao dien ---- */

$k23_cong_cu = array(
    array(
        'ten'   => 'Git',
        'icon'  => 'account_tree',
        'mau'   => '#F05032',
        'rgb'   => '240,80,50',
        'mo_ta' => 'Kiem soat phien ban phan tan, quan ly ma nguon linh hoat.',
    ),
    array(
        'ten'   => 'GitHub',
        'icon'  => 'code',
        'mau'   => '#ffffff',
        'rgb'   => '255,255,255',
        'mo_ta' => 'Luu tru ma nguon, hop tac phat trien va GitHub Actions.',
    ),
    array(
        'ten'   => 'GitLab',
        'icon'  => 'all_inclusive',
        'mau'   => '#FC6D26',
        'rgb'   => '252,109,38',
        'mo_ta' => 'Nen tang DevOps toan dien, tich hop CI/CD manh me.',
    ),
    array(
        'ten'   => 'Docker Compose',
        'icon'  => 'layers',
        'mau'   => '#2496ED',
        'rgb'   => '36,150,237',
        'mo_ta' => 'Dieu phoi moi truong da container de dang va nhat quan.',
    ),
);

$k23_terminal = array(
    array('lenh' => 'whoami',          'ket_qua' => 'Sinh vien Khoi nghiep &amp; DevOps Engineer'),
    array('lenh' => 'cat su_menh.txt', 'ket_qua' => 'Tu dong hoa, Toi uu hoa, Trien khai.'),
    array('lenh' => 'git log -1 --oneline', 'ket_qua' => esc_html($k23_commit)),
);

$k23_lien_ket = array(
    array('nhan' => 'GitHub',        'url' => 'https://' . $k23_repo),
    array('nhan' => 'Trang chu',     'url' => home_url('/')),
    array('nhan' => 'Quan tri',      'url' => admin_url()),
    array('nhan' => 'Tai lieu',      'url' => home_url('/')),
);
?>
<!DOCTYPE html>
<html class="dark" <?php language_attributes(); ?>>
<head>
<meta charset="<?php bloginfo('charset'); ?>"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com" rel="preconnect"/>
<link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&amp;family=JetBrains+Mono:wght@400;600&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
tailwind.config = {
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        "background": "#051424",
        "surface": "#051424",
        "surface-dim": "#051424",
        "surface-bright": "#2c3a4c",
        "surface-variant": "#273647",
        "surface-container-lowest": "#010f1f",
        "surface-container-low": "#0d1c2d",
        "surface-container": "#122131",
        "surface-container-high": "#1c2b3c",
        "surface-container-highest": "#273647",
        "on-background": "#d4e4fa",
        "on-surface": "#d4e4fa",
        "on-surface-variant": "#bbcabf",
        "primary": "#4edea3",
        "primary-fixed": "#6ffbbe",
        "primary-fixed-dim": "#4edea3",
        "primary-container": "#10b981",
        "on-primary": "#003824",
        "on-primary-container": "#00422b",
        "secondary": "#bec6e0",
        "secondary-container": "#3f465c",
        "on-secondary": "#283044",
        "tertiary": "#7bd0ff",
        "tertiary-container": "#19aee8",
        "on-tertiary": "#00354a",
        "error": "#ffb4ab",
        "outline": "#86948a",
        "outline-variant": "#3c4a42",
        "surface-tint": "#4edea3"
      },
      borderRadius: { "DEFAULT": "0.125rem", "lg": "0.25rem", "xl": "0.5rem", "full": "0.75rem" },
      spacing: { "max-width": "1200px", "base": "4px", "xs": "8px", "sm": "16px", "md": "24px", "lg": "48px", "xl": "80px" },
      fontFamily: {
        "body-base": ["Inter"], "display-lg": ["Inter"], "display-lg-mobile": ["Inter"],
        "headline-md": ["Inter"], "code-sm": ["JetBrains Mono"], "label-caps": ["JetBrains Mono"]
      },
      fontSize: {
        "body-base": ["16px", { "lineHeight": "24px", "fontWeight": "400" }],
        "display-lg": ["48px", { "lineHeight": "56px", "letterSpacing": "-0.02em", "fontWeight": "700" }],
        "display-lg-mobile": ["32px", { "lineHeight": "40px", "letterSpacing": "-0.02em", "fontWeight": "700" }],
        "headline-md": ["24px", { "lineHeight": "32px", "fontWeight": "600" }],
        "code-sm": ["14px", { "lineHeight": "20px", "fontWeight": "400" }],
        "label-caps": ["12px", { "lineHeight": "16px", "fontWeight": "600" }]
      }
    }
  }
}
</script>
<style>
body { background-color:#051424; color:#d4e4fa; }
.bg-grid-pattern {
  background-image: linear-gradient(to right, rgba(60,74,66,.2) 1px, transparent 1px),
                    linear-gradient(to bottom, rgba(60,74,66,.2) 1px, transparent 1px);
  background-size: 40px 40px;
}
.glass-card {
  background-color: rgba(18,33,49,.6);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid #3c4a42;
}
.glass-card:hover { border-color:#4edea3; box-shadow:0 0 15px rgba(78,222,163,.1); }
.cursor-blink { animation: blink 1s step-end infinite; }
@keyframes blink { 0%,100%{opacity:1} 50%{opacity:0} }
.terminal-window { background-color:#020617; border-radius:.5rem; overflow:hidden; border:1px solid #3c4a42; }
.terminal-header { background-color:#122131; padding:8px 12px; display:flex; align-items:center; border-bottom:1px solid #3c4a42; }
.terminal-dots { display:flex; gap:6px; }
.terminal-dot { width:12px; height:12px; border-radius:50%; }
.dot-red{background:#ff5f56} .dot-yellow{background:#ffbd2e} .dot-green{background:#27c93f}
/* Chua thanh admin bar cua WordPress de header cong khong bi che */
body.admin-bar header.k23-nav { top: 32px; }
@media screen and (max-width: 782px) { body.admin-bar header.k23-nav { top: 46px; } }
</style>
<?php wp_head(); ?>
</head>
<body <?php body_class('font-body-base text-body-base bg-background text-on-surface antialiased min-h-screen flex flex-col'); ?>>

<!-- TopNavBar -->
<header class="k23-nav fixed top-0 w-full z-50 bg-background/80 backdrop-blur-xl border-b border-outline-variant">
  <div class="max-w-[1200px] mx-auto px-md h-16 flex items-center justify-between">
    <div class="font-code-sm text-label-caps font-bold text-primary tracking-tighter">DEVOPS_PORTFOLIO</div>

    <nav class="hidden md:flex items-center gap-md">
      <a class="font-code-sm text-code-sm text-primary border-b-2 border-primary pb-1 transition-all duration-300" href="<?php echo esc_url(get_permalink()); ?>">Portfolio</a>
      <a class="font-code-sm text-code-sm text-on-surface-variant hover:text-primary transition-colors duration-300" href="#cong-cu">Cong cu</a>
      <a class="font-code-sm text-code-sm text-on-surface-variant hover:text-primary transition-colors duration-300" href="#chuyen-mon">Chuyen mon</a>
      <a class="font-code-sm text-code-sm text-on-surface-variant hover:text-primary transition-colors duration-300" href="<?php echo esc_url(home_url('/')); ?>">Trang chu</a>
    </nav>

    <a class="hidden md:inline-flex items-center justify-center px-sm py-xs bg-primary-container text-on-primary-container font-code-sm text-code-sm rounded hover:bg-primary transition-colors duration-300"
       href="<?php echo esc_url('https://' . $k23_repo); ?>" target="_blank" rel="noopener">
      Xem ma nguon
    </a>

    <a class="md:hidden text-on-surface-variant p-2" href="<?php echo esc_url(home_url('/')); ?>" aria-label="Ve trang chu">
      <span class="material-symbols-outlined">home</span>
    </a>
  </div>
</header>

<main class="flex-grow pt-24 pb-xl">

  <!-- Hero -->
  <section class="relative max-w-[1200px] mx-auto px-md min-h-[640px] flex items-center mb-xl">
    <div class="absolute inset-0 bg-grid-pattern opacity-50 z-0 pointer-events-none"></div>

    <div class="relative z-10 w-full grid grid-cols-1 md:grid-cols-2 gap-lg items-center">
      <div>
        <div class="inline-flex items-center gap-2 px-3 py-1 rounded bg-surface-container-high border border-outline-variant mb-6">
          <span class="w-2 h-2 rounded-full bg-primary animate-pulse"></span>
          <span class="font-code-sm text-label-caps text-on-surface-variant">HE THONG TRUC TUYEN &mdash; <?php echo esc_html(gethostname()); ?></span>
        </div>

        <h1 class="font-display-lg-mobile md:font-display-lg text-on-surface mb-6">
          Kien tao <span class="text-primary">Tuong Lai</span><br/>
          voi Co So Ha Tang.
        </h1>

        <div class="terminal-window mb-8 shadow-lg">
          <div class="terminal-header">
            <div class="terminal-dots">
              <div class="terminal-dot dot-red"></div>
              <div class="terminal-dot dot-yellow"></div>
              <div class="terminal-dot dot-green"></div>
            </div>
            <div class="ml-4 font-code-sm text-xs text-on-surface-variant">bash -- 80x24</div>
          </div>
          <div class="p-4 font-code-sm text-code-sm">
            <?php foreach ($k23_terminal as $dong) : ?>
              <p class="text-primary">$ <?php echo esc_html($dong['lenh']); ?></p>
              <p class="text-on-surface mb-2"><?php echo $dong['ket_qua']; ?></p>
            <?php endforeach; ?>
            <p class="text-primary">$ <span class="cursor-blink">_</span></p>
          </div>
        </div>

        <div class="flex gap-4">
          <a class="px-6 py-3 bg-primary text-background font-code-sm font-semibold rounded hover:bg-primary-fixed transition-colors shadow-[0_0_15px_rgba(78,222,163,0.3)]"
             href="#chuyen-mon">Xem Du An</a>
          <a class="px-6 py-3 bg-transparent border border-outline text-primary font-code-sm font-semibold rounded hover:border-primary transition-colors"
             href="<?php echo esc_url(home_url('/')); ?>">Ve Trang Chu</a>
        </div>
      </div>

      <div class="hidden md:block relative h-full min-h-[400px]">
        <div class="absolute inset-0 flex items-center justify-center">
          <div class="w-full max-w-sm aspect-square relative">
            <img class="object-cover rounded-xl border border-outline-variant shadow-2xl h-full w-full opacity-80 mix-blend-screen"
                 alt="Minh hoa cac tu may chu va luong du lieu trong moi truong dien toan dam may"
                 src="https://lh3.googleusercontent.com/aida-public/AB6AXuBRlbYe1bdzy5Syl36d3I31yHWDRkHGkyd6qpXWoYT1lMYYfuISssDNfXCuXeolfx6kvOncVw_rUjH_Wxdqt6CuElkS0ov4HparBCorTuJAbGqBXpFs4uHmd9ovSdQyXt-lh4nzixiHuoBpqm4iK6H2As2gdt-bbgCetpA3fYiXtIxFjbaICWkNmKyycZWxEVin48qR2XWU0ZhT8KwZ6mn4jhnepaHAivOZW5dMqPpt6GvDnP0NjV0"/>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- Cong cu cot loi -->
  <section id="cong-cu" class="max-w-[1200px] mx-auto px-md py-xl relative scroll-mt-24">
    <div class="mb-12">
      <h2 class="font-headline-md text-on-surface mb-2">Cong Cu Cot Loi</h2>
      <p class="font-body-base text-on-surface-variant">Nen tang ky thuat cho quy trinh phat trien va trien khai lien tuc.</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <?php foreach ($k23_cong_cu as $cc) : ?>
        <div class="glass-card p-6 rounded-xl transition-all duration-300 group">
          <div class="w-12 h-12 flex items-center justify-center rounded-lg bg-surface-container-high mb-4 text-on-surface-variant transition-all"
               style="--k23-mau: <?php echo esc_attr($cc['mau']); ?>"
               onmouseover="this.style.color='<?php echo esc_js($cc['mau']); ?>';this.style.boxShadow='0 0 10px rgba(<?php echo esc_js($cc['rgb']); ?>,0.5)'"
               onmouseout="this.style.color='';this.style.boxShadow=''">
            <span class="material-symbols-outlined text-3xl"><?php echo esc_html($cc['icon']); ?></span>
          </div>
          <h3 class="font-code-sm font-bold text-on-surface mb-2"><?php echo esc_html($cc['ten']); ?></h3>
          <p class="font-body-base text-sm text-on-surface-variant"><?php echo esc_html($cc['mo_ta']); ?></p>
        </div>
      <?php endforeach; ?>
    </div>
  </section>

  <!-- Chuyen mon (bento grid) -->
  <section id="chuyen-mon" class="max-w-[1200px] mx-auto px-md py-xl scroll-mt-24">
    <div class="mb-12">
      <h2 class="font-headline-md text-on-surface mb-2">Chuyen Mon</h2>
      <p class="font-body-base text-on-surface-variant">Cac linh vuc tap trung de xay dung he thong phan mem ben vung.</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 md:auto-rows-[250px]">

      <div class="md:col-span-2 glass-card rounded-xl p-6 relative overflow-hidden flex flex-col justify-end min-h-[250px]">
        <div class="absolute inset-0 bg-gradient-to-t from-surface-container to-transparent z-10"></div>
        <img class="absolute inset-0 w-full h-full object-cover opacity-40 mix-blend-luminosity z-0"
             alt="So do mot pipeline CI/CD hien dai"
             src="https://lh3.googleusercontent.com/aida-public/AB6AXuDanW2VO1Ub4SjjGpFLYQJjTEnN4dzdFx5FhuQtwwGD6JSuLQhNUTE_GUobHFLjJ3BCpSJQdH3n9AZ96VGGJVjwz_gbCsOMDbK3NzNXkT-jrqXJEca9sxQjVI2Y_Fx1No4sUlmYMSxbTfbZ_HSMrWiuBgFIqfPMSZ3tVP3aYKnerWMizE1nPqVYOjSKdlfJ9hXn1zBpufqvutTSmbzHSVDrdVYdiPAMWHou1zv66HOp0yAEmjETnjg"/>
        <div class="relative z-20">
          <h3 class="font-headline-md text-on-surface mb-2">CI/CD Pipelines</h3>
          <p class="font-body-base text-on-surface-variant max-w-md">Tu dong hoa toan bo quy trinh tu kiem thu den trien khai, dam bao phan phoi phan mem nhanh chong va an toan.</p>
        </div>
      </div>

      <div class="glass-card rounded-xl p-6 relative overflow-hidden flex flex-col justify-between min-h-[250px]">
        <div class="w-10 h-10 rounded-full bg-surface-container-high flex items-center justify-center border border-outline-variant">
          <span class="material-symbols-outlined text-primary">terminal</span>
        </div>
        <div>
          <h3 class="font-headline-md text-on-surface mb-2">IaC</h3>
          <p class="font-body-base text-sm text-on-surface-variant">Quan ly va cau hinh ha tang qua ma nguon (Terraform, Ansible), loai bo thao tac thu cong.</p>
        </div>
      </div>

      <div class="glass-card rounded-xl p-6 relative flex flex-col justify-between border-t-2 border-t-primary min-h-[250px]">
        <div class="flex items-center gap-2 font-code-sm text-xs text-primary mb-4">
          <span class="relative flex h-3 w-3">
            <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
            <span class="relative inline-flex rounded-full h-3 w-3 bg-primary"></span>
          </span>
          STATUS: HEALTHY
        </div>
        <div>
          <h3 class="font-headline-md text-on-surface mb-2">Giam Sat He Thong</h3>
          <p class="font-body-base text-sm text-on-surface-variant">Trien khai Prometheus &amp; Grafana de theo doi hieu suat va canh bao thoi gian thuc.</p>
        </div>
      </div>

      <div class="md:col-span-2 glass-card rounded-xl p-6 flex flex-col justify-center items-center text-center relative overflow-hidden min-h-[250px]">
        <div class="absolute inset-0 bg-grid-pattern opacity-20 pointer-events-none"></div>
        <span class="material-symbols-outlined text-6xl text-surface-variant mb-4">hub</span>
        <h3 class="font-headline-md text-on-surface mb-2">Kien Truc Microservices</h3>
        <p class="font-body-base text-on-surface-variant max-w-lg">Thiet ke va van hanh cac dich vu doc lap, co kha nang mo rong cao tren moi truong Kubernetes.</p>
      </div>

    </div>
  </section>

  <!-- Phien ban dang chay: bang chung chuoi AI -> GitHub -> may ao -->
  <section class="max-w-[1200px] mx-auto px-md">
    <div class="glass-card rounded-xl p-6">
      <div class="font-code-sm text-label-caps text-primary mb-4">PHIEN BAN DANG CHAY</div>
      <div class="grid grid-cols-2 md:grid-cols-4 gap-6 font-code-sm text-code-sm">
        <div>
          <div class="text-on-surface-variant text-xs mb-1">Theme</div>
          <div class="text-on-surface">K23 v<?php echo esc_html($k23_ver); ?></div>
        </div>
        <div>
          <div class="text-on-surface-variant text-xs mb-1">Commit</div>
          <div class="text-primary"><?php echo esc_html($k23_commit); ?></div>
        </div>
        <div>
          <div class="text-on-surface-variant text-xs mb-1">May chu</div>
          <div class="text-on-surface"><?php echo esc_html(gethostname()); ?></div>
        </div>
        <div>
          <div class="text-on-surface-variant text-xs mb-1">Thoi gian tai</div>
          <div class="text-on-surface"><?php echo number_format((microtime(true) - $k23_bat_dau) * 1000, 2); ?> ms</div>
        </div>
      </div>
      <p class="font-body-base text-sm text-on-surface-variant mt-4">
        Ma commit o tren do script <span class="font-code-sm text-on-surface">vm/capnhat.sh</span> ghi vao file
        <span class="font-code-sm text-on-surface">COMMIT.txt</span> sau moi lan <span class="font-code-sm text-on-surface">git pull</span>.
        Doi chieu no voi commit moi nhat tren <?php echo esc_html($k23_repo); ?> de xac nhan may ao dang chay dung phien ban vua day len.
      </p>
    </div>
  </section>

</main>

<footer class="w-full py-xl bg-surface-container-lowest border-t border-outline-variant mt-xl">
  <div class="max-w-[1200px] mx-auto px-md flex flex-col md:flex-row justify-between items-center gap-base">
    <div class="font-code-sm text-label-caps text-on-surface-variant">
      &copy; <?php echo esc_html(date('Y')); ?> <?php echo esc_html(get_bloginfo('name')); ?>. All systems operational.
    </div>
    <nav class="flex gap-4 flex-wrap justify-center">
      <?php foreach ($k23_lien_ket as $lk) : ?>
        <a class="font-code-sm text-code-sm text-on-surface-variant hover:text-tertiary transition-colors"
           href="<?php echo esc_url($lk['url']); ?>"><?php echo esc_html($lk['nhan']); ?></a>
      <?php endforeach; ?>
    </nav>
  </div>
</footer>

<?php wp_footer(); ?>
</body>
</html>

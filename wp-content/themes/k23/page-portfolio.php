<?php
/**
 * Template Name: Portfolio DevOps
 *
 * Trang giao diện độc lập, KHÔNG dùng header.php và footer.php của theme,
 * nên không ảnh hưởng gì tới trang chủ và danh sách bài viết đang chạy.
 * Muốn gỡ bỏ chỉ cần xóa file này hoặc đổi mẫu của trang về "Mặc định".
 */

// Đọc mã commit mà capnhat.sh ghi vào — dùng cho khối terminal ở phần đầu trang
$k23_commit = trim(@file_get_contents(get_template_directory() . '/COMMIT.txt'));
if ($k23_commit === '') { $k23_commit = 'chua co commit'; }
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
    theme: { extend: {
      colors: {
        "on-secondary-fixed":"#131b2e","on-background":"#d4e4fa","surface-bright":"#2c3a4c",
        "on-primary-fixed-variant":"#005236","background":"#051424","on-primary":"#003824",
        "tertiary-container":"#19aee8","surface-container-high":"#1c2b3c","tertiary-fixed":"#c4e7ff",
        "on-secondary":"#283044","tertiary-fixed-dim":"#7bd0ff","secondary-container":"#3f465c",
        "secondary-fixed":"#dae2fd","surface":"#051424","secondary":"#bec6e0",
        "on-secondary-container":"#adb4ce","on-primary-container":"#00422b","on-error-container":"#ffdad6",
        "surface-container-low":"#0d1c2d","on-tertiary-fixed":"#001e2c","inverse-surface":"#d4e4fa",
        "primary-fixed":"#6ffbbe","outline":"#86948a","primary-container":"#10b981",
        "on-tertiary-container":"#003e55","error-container":"#93000a","on-secondary-fixed-variant":"#3f465c",
        "surface-container-highest":"#273647","primary":"#4edea3","on-surface":"#d4e4fa",
        "outline-variant":"#3c4a42","on-tertiary-fixed-variant":"#004c69","on-error":"#690005",
        "surface-variant":"#273647","surface-dim":"#051424","surface-container-lowest":"#010f1f",
        "secondary-fixed-dim":"#bec6e0","on-tertiary":"#00354a","inverse-on-surface":"#233143",
        "surface-container":"#122131","on-primary-fixed":"#002113","primary-fixed-dim":"#4edea3",
        "error":"#ffb4ab","surface-tint":"#4edea3","tertiary":"#7bd0ff","inverse-primary":"#006c49",
        "on-surface-variant":"#bbcabf"
      },
      borderRadius: { DEFAULT:"0.125rem", lg:"0.25rem", xl:"0.5rem", full:"0.75rem" },
      spacing: { "max-width":"1200px", md:"24px", xl:"80px", sm:"16px", xs:"8px", lg:"48px", base:"4px" },
      fontFamily: {
        "body-base":["Inter"],"display-lg":["Inter"],"code-sm":["JetBrains Mono"],
        "display-lg-mobile":["Inter"],"headline-md":["Inter"],"label-caps":["JetBrains Mono"]
      },
      fontSize: {
        "body-base":["16px",{lineHeight:"24px",fontWeight:"400"}],
        "display-lg":["48px",{lineHeight:"56px",letterSpacing:"-0.02em",fontWeight:"700"}],
        "code-sm":["14px",{lineHeight:"20px",fontWeight:"400"}],
        "display-lg-mobile":["32px",{lineHeight:"40px",letterSpacing:"-0.02em",fontWeight:"700"}],
        "headline-md":["24px",{lineHeight:"32px",fontWeight:"600"}],
        "label-caps":["12px",{lineHeight:"16px",fontWeight:"600"}]
      }
    }}
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
    backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px);
    border: 1px solid #3c4a42;
  }
  .glass-card:hover { border-color:#4edea3; box-shadow:0 0 15px rgba(78,222,163,.1); }
  .cursor-blink { animation: blink 1s step-end infinite; }
  @keyframes blink { 0%,100%{opacity:1} 50%{opacity:0} }
  .terminal-window { background-color:#020617; border-radius:.5rem; overflow:hidden; border:1px solid #3c4a42; }
  .terminal-header { background-color:#122131; padding:8px 12px; display:flex; align-items:center; border-bottom:1px solid #3c4a42; }
  .terminal-dots { display:flex; gap:6px; }
  .terminal-dot { width:12px; height:12px; border-radius:50%; }
  .dot-red{background:#ff5f56}.dot-yellow{background:#ffbd2e}.dot-green{background:#27c93f}
  /* Thanh quản trị của WordPress dùng nền sáng, đẩy nội dung xuống cho khỏi che */
  body.admin-bar header.k23-nav { top: 32px; }
</style>
<?php wp_head(); ?>
</head>

<body <?php body_class('font-body-base text-body-base bg-background text-on-surface antialiased min-h-screen flex flex-col'); ?>>

<!-- Thanh điều hướng -->
<header class="k23-nav fixed top-0 w-full z-50 bg-background/80 backdrop-blur-xl border-b border-outline-variant">
  <div class="max-w-[1200px] mx-auto px-md h-16 flex items-center justify-between">
    <div class="font-code-sm text-label-caps font-bold text-primary tracking-tighter">
      <?php echo esc_html(strtoupper(str_replace(' ', '_', get_bloginfo('name')))); ?>
    </div>
    <nav class="hidden md:flex items-center gap-md">
      <a class="font-code-sm text-code-sm text-primary border-b-2 border-primary pb-1" href="#">Portfolio</a>
      <a class="font-code-sm text-code-sm text-on-surface-variant hover:text-primary transition-colors" href="#cong-cu">Công cụ</a>
      <a class="font-code-sm text-code-sm text-on-surface-variant hover:text-primary transition-colors" href="#chuyen-mon">Chuyên môn</a>
      <a class="font-code-sm text-code-sm text-on-surface-variant hover:text-primary transition-colors"
         href="<?php echo esc_url(home_url('/')); ?>">Trang chủ</a>
    </nav>
    <a href="<?php echo esc_url(home_url('/')); ?>"
       class="hidden md:inline-flex items-center justify-center px-sm py-xs bg-primary-container text-on-primary-container font-code-sm text-code-sm rounded hover:bg-primary transition-colors duration-300">
      Về trang chủ
    </a>
    <button class="md:hidden text-on-surface-variant p-2">
      <span class="material-symbols-outlined">menu</span>
    </button>
  </div>
</header>

<main class="flex-grow pt-24 pb-xl">

  <!-- Phần đầu trang -->
  <section class="relative max-w-[1200px] mx-auto px-md min-h-[70vh] flex items-center mb-xl">
    <div class="absolute inset-0 bg-grid-pattern opacity-50 z-0 pointer-events-none"></div>
    <div class="relative z-10 w-full grid grid-cols-1 md:grid-cols-2 gap-lg items-center">
      <div>
        <div class="inline-flex items-center gap-2 px-3 py-1 rounded bg-surface-container-high border border-outline-variant mb-6">
          <span class="w-2 h-2 rounded-full bg-primary animate-pulse"></span>
          <span class="font-code-sm text-label-caps text-on-surface-variant">HỆ THỐNG TRỰC TUYẾN</span>
        </div>

        <h1 class="font-display-lg-mobile md:font-display-lg text-on-surface mb-6">
          Kiến tạo <span class="text-primary">Tương Lai</span><br/>với Cơ Sở Hạ Tầng.
        </h1>

        <!-- Khối terminal — hiển thị đúng commit mà máy chủ đang chạy -->
        <div class="terminal-window mb-8 shadow-lg">
          <div class="terminal-header">
            <div class="terminal-dots">
              <div class="terminal-dot dot-red"></div>
              <div class="terminal-dot dot-yellow"></div>
              <div class="terminal-dot dot-green"></div>
            </div>
            <div class="ml-4 font-code-sm text-xs text-on-surface-variant">bash — 80x24</div>
          </div>
          <div class="p-4 font-code-sm text-code-sm">
            <p class="text-primary">$ whoami</p>
            <p class="text-on-surface mb-2">Sinh viên học phần SDM332 — Triển khai và quản trị hệ thống phần mềm</p>
            <p class="text-primary">$ hostname</p>
            <p class="text-on-surface mb-2"><?php echo esc_html(gethostname()); ?></p>
            <p class="text-primary">$ git log -1 --oneline</p>
            <p class="text-on-surface mb-2"><?php echo esc_html($k23_commit); ?></p>
            <p class="text-primary">$ date</p>
            <p class="text-on-surface mb-2"><?php echo esc_html(date('H:i:s d/m/Y')); ?></p>
            <p class="text-primary">$ <span class="cursor-blink">_</span></p>
          </div>
        </div>

        <div class="flex gap-4">
          <a href="#chuyen-mon" class="px-6 py-3 bg-primary text-background font-code-sm font-semibold rounded hover:bg-primary-fixed transition-colors shadow-[0_0_15px_rgba(78,222,163,0.3)]">
            Xem chuyên môn
          </a>
          <a href="<?php echo esc_url(home_url('/')); ?>" class="px-6 py-3 bg-transparent border border-outline text-primary font-code-sm font-semibold rounded hover:border-primary transition-colors">
            Xem bài viết
          </a>
        </div>
      </div>

      <div class="hidden md:block relative h-full min-h-[400px]">
        <div class="absolute inset-0 flex items-center justify-center">
          <div class="w-full max-w-sm aspect-square relative">
            <img class="object-cover rounded-xl border border-outline-variant shadow-2xl h-full w-full opacity-80 mix-blend-screen"
                 alt="Minh họa hạ tầng máy chủ và luồng dữ liệu"
                 src="https://lh3.googleusercontent.com/aida-public/AB6AXuBRlbYe1bdzy5Syl36d3I31yHWDRkHGkyd6qpXWoYT1lMYYfuISssDNfXCuXeolfx6kvOncVw_rUjH_Wxdqt6CuElkS0ov4HparBCorTuJAbGqBXpFs4uHmd9ovSdQyXt-lh4nzixiHuoBpqm4iK6H2As2gdt-bbgCetpA3fYiXtIxFjbaICWkNmKyycZWxEVin48qR2XWU0ZhT8KwZ6mn4jhnepaHAivOZW5dMqPpt6GvDnP0NjV0"/>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- Công cụ cốt lõi -->
  <section id="cong-cu" class="max-w-[1200px] mx-auto px-md py-xl relative scroll-mt-24">
    <div class="mb-12">
      <h2 class="font-headline-md text-on-surface mb-2">Công Cụ Cốt Lõi</h2>
      <p class="font-body-base text-on-surface-variant">Nền tảng kỹ thuật cho quy trình phát triển và triển khai liên tục.</p>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <?php
      $k23_tools = [
        ['account_tree', 'Git', 'Kiểm soát phiên bản phân tán, quản lý mã nguồn linh hoạt.', 'group-hover:text-[#F05032]'],
        ['code', 'GitHub', 'Lưu trữ mã nguồn, hợp tác phát triển và GitHub Actions.', 'group-hover:text-white'],
        ['all_inclusive', 'GitLab', 'Nền tảng DevOps toàn diện, tích hợp CI/CD mạnh mẽ.', 'group-hover:text-[#FC6D26]'],
        ['layers', 'Docker Compose', 'Điều phối môi trường đa container dễ dàng và nhất quán.', 'group-hover:text-[#2496ED]'],
      ];
      foreach ($k23_tools as $t) : ?>
        <div class="glass-card p-6 rounded-xl transition-all duration-300 group">
          <div class="w-12 h-12 flex items-center justify-center rounded-lg bg-surface-container-high mb-4 text-on-surface-variant <?php echo esc_attr($t[3]); ?> transition-all">
            <span class="material-symbols-outlined text-3xl"><?php echo esc_html($t[0]); ?></span>
          </div>
          <h3 class="font-code-sm font-bold text-on-surface mb-2"><?php echo esc_html($t[1]); ?></h3>
          <p class="font-body-base text-sm text-on-surface-variant"><?php echo esc_html($t[2]); ?></p>
        </div>
      <?php endforeach; ?>
    </div>
  </section>

  <!-- Chuyên môn -->
  <section id="chuyen-mon" class="max-w-[1200px] mx-auto px-md py-xl scroll-mt-24">
    <div class="mb-12">
      <h2 class="font-headline-md text-on-surface mb-2">Chuyên Môn</h2>
      <p class="font-body-base text-on-surface-variant">Các lĩnh vực tập trung để xây dựng hệ thống phần mềm bền vững.</p>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 auto-rows-[250px]">

      <div class="md:col-span-2 glass-card rounded-xl p-6 relative overflow-hidden flex flex-col justify-end">
        <div class="absolute inset-0 bg-gradient-to-t from-surface-container to-transparent z-10"></div>
        <img class="absolute inset-0 w-full h-full object-cover opacity-40 mix-blend-luminosity z-0"
             alt="Sơ đồ pipeline CI/CD"
             src="https://lh3.googleusercontent.com/aida-public/AB6AXuDanW2VO1Ub4SjjGpFLYQJjTEnN4dzdFx5FhuQtwwGD6JSuLQhNUTE_GUobHFLjJ3BCpSJQdH3n9AZ96VGGJVjwz_gbCsOMDbK3NzNXkT-jrqXJEca9sxQjVI2Y_Fx1No4sUlmYMSxbTfbZ_HSMrWiuBgFIqfPMSZ3tVP3aYKnerWMizE1nPqVYOjSKdlfJ9hXn1zBpufqvutTSmbzHSVDrdVYdiPAMWHou1zv66HOp0yAEmjETnjg"/>
        <div class="relative z-20">
          <h3 class="font-headline-md text-on-surface mb-2">CI/CD Pipelines</h3>
          <p class="font-body-base text-on-surface-variant max-w-md">Tự động hóa toàn bộ quy trình từ kiểm thử đến triển khai, đảm bảo phân phối phần mềm nhanh chóng và an toàn.</p>
        </div>
      </div>

      <div class="glass-card rounded-xl p-6 relative overflow-hidden flex flex-col justify-between">
        <div class="w-10 h-10 rounded-full bg-surface-container-high flex items-center justify-center border border-outline-variant">
          <span class="material-symbols-outlined text-primary">terminal</span>
        </div>
        <div>
          <h3 class="font-headline-md text-on-surface mb-2">IaC</h3>
          <p class="font-body-base text-sm text-on-surface-variant">Quản lý và cấu hình hạ tầng qua mã nguồn, loại bỏ thao tác thủ công.</p>
        </div>
      </div>

      <div class="glass-card rounded-xl p-6 relative flex flex-col justify-between border-t-2 border-t-primary">
        <div class="flex items-center gap-2 font-code-sm text-xs text-primary mb-4">
          <span class="relative flex h-3 w-3">
            <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
            <span class="relative inline-flex rounded-full h-3 w-3 bg-primary"></span>
          </span>
          STATUS: HEALTHY
        </div>
        <div>
          <h3 class="font-headline-md text-on-surface mb-2">Giám Sát Hệ Thống</h3>
          <p class="font-body-base text-sm text-on-surface-variant">Triển khai Prometheus &amp; Grafana để theo dõi hiệu suất và cảnh báo thời gian thực.</p>
        </div>
      </div>

      <div class="md:col-span-2 glass-card rounded-xl p-6 flex flex-col justify-center items-center text-center relative overflow-hidden">
        <div class="absolute inset-0 bg-grid-pattern opacity-20 pointer-events-none"></div>
        <span class="material-symbols-outlined text-6xl text-surface-variant mb-4">hub</span>
        <h3 class="font-headline-md text-on-surface mb-2">Kiến Trúc Microservices</h3>
        <p class="font-body-base text-on-surface-variant max-w-lg">Thiết kế và vận hành các dịch vụ độc lập, có khả năng mở rộng cao trên môi trường Kubernetes.</p>
      </div>
    </div>
  </section>

  <!-- Nội dung soạn trong trang WordPress, nếu có -->
  <?php if (have_posts()) : while (have_posts()) : the_post();
      $k23_noi_dung = trim(get_the_content());
      if ($k23_noi_dung !== '') : ?>
        <section class="max-w-[1200px] mx-auto px-md py-xl">
          <div class="glass-card rounded-xl p-6 prose prose-invert max-w-none">
            <?php the_content(); ?>
          </div>
        </section>
      <?php endif;
  endwhile; endif; ?>

</main>

<footer class="w-full py-xl bg-surface-container-lowest border-t border-outline-variant">
  <div class="max-w-[1200px] mx-auto px-md flex flex-col md:flex-row justify-between items-center gap-base">
    <div class="font-code-sm text-label-caps text-on-surface-variant">
      © <?php echo esc_html(date('Y')); ?> <?php echo esc_html(get_bloginfo('name')); ?> — All systems operational.
    </div>
    <nav class="flex gap-4 font-code-sm text-code-sm">
      <span class="text-on-surface-variant">Theme K23 v<?php echo esc_html(defined('K23_VERSION') ? K23_VERSION : '1.0'); ?></span>
      <span class="text-tertiary"><?php echo esc_html($k23_commit); ?></span>
      <a class="text-on-surface-variant hover:text-tertiary transition-colors" href="<?php echo esc_url(home_url('/')); ?>">Trang chủ</a>
    </nav>
  </div>
</footer>

<?php wp_footer(); ?>
</body>
</html>

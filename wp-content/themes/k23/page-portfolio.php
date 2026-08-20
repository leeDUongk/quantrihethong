<?php
/**
 * Template Name: Portfolio DevOps
 *
 * Trang giao diện độc lập. KHÔNG dùng header.php và footer.php của theme,
 * nên không ảnh hưởng gì tới trang chủ và danh sách bài viết đang chạy.
 * Muốn gỡ bỏ: xóa file này, hoặc đổi Mẫu của trang về "Mặc định".
 */

// Mã commit do capnhat.sh ghi vào — hiển thị ở chân trang để kiểm chứng phiên bản
$k23_commit = trim(@file_get_contents(get_template_directory() . '/COMMIT.txt'));
if ($k23_commit === '') { $k23_commit = 'chua co commit'; }
$k23_ver = defined('K23_VERSION') ? K23_VERSION : '1.0';
?>
<!DOCTYPE html>
<html class="light" <?php language_attributes(); ?>>
<head>
<meta charset="<?php bloginfo('charset'); ?>"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Anybody:wght@400;600;700;800&amp;family=Be+Vietnam+Pro:wght@400;500;700&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
  tailwind.config = {
    darkMode: "class",
    theme: { extend: {
      colors: {
        "error":"#ba1a1a","surface-variant":"#e2e2e2","tertiary":"#5f5e5e","error-container":"#ffdad6",
        "on-primary-fixed":"#161e00","on-tertiary":"#ffffff","on-background":"#1a1c1c",
        "primary-fixed-dim":"#abd600","secondary-container":"#e4006c","on-error":"#ffffff",
        "on-error-container":"#93000a","on-tertiary-fixed":"#1c1b1b","surface-container-lowest":"#ffffff",
        "secondary-fixed-dim":"#ffb1c3","on-secondary-fixed":"#3f0019","surface-container-highest":"#e2e2e2",
        "outline":"#747a60","surface-container":"#eeeeee","surface":"#f9f9f9","tertiary-fixed":"#e5e2e1",
        "surface-dim":"#dadada","background":"#f9f9f9","secondary":"#b60055","tertiary-container":"#efeceb",
        "on-tertiary-container":"#6c6a6a","tertiary-fixed-dim":"#c8c6c5","primary-fixed":"#c3f400",
        "outline-variant":"#c4c9ac","on-surface-variant":"#444933","surface-container-high":"#e8e8e8",
        "on-primary-fixed-variant":"#3c4d00","on-secondary":"#ffffff","inverse-surface":"#2f3131",
        "secondary-fixed":"#ffd9e0","inverse-on-surface":"#f0f1f1","on-surface":"#1a1c1c",
        "surface-bright":"#f9f9f9","primary":"#506600","surface-tint":"#506600","inverse-primary":"#abd600",
        "on-tertiary-fixed-variant":"#474646","surface-container-low":"#f3f3f4","primary-container":"#ccff00",
        "on-primary":"#ffffff","on-secondary-container":"#fffbff","on-secondary-fixed-variant":"#8f0041",
        "on-primary-container":"#5b7300"
      },
      borderRadius: { DEFAULT:"0.25rem", lg:"0.5rem", xl:"0.75rem", full:"9999px" },
      spacing: { "container-max":"1440px", xs:"4px", base:"8px", lg:"48px", sm:"12px",
                 gutter:"20px", md:"24px", xl:"80px" },
      fontFamily: {
        "headline-lg-mobile":["Anybody"],"label-bold":["Be Vietnam Pro"],"headline-lg":["Anybody"],
        "body-md":["Be Vietnam Pro"],"display-xl":["Anybody"],"title-md":["Anybody"],
        "caption":["Be Vietnam Pro"],"body-lg":["Be Vietnam Pro"]
      },
      fontSize: {
        "headline-lg-mobile":["32px",{lineHeight:"40px",letterSpacing:"-0.01em",fontWeight:"700"}],
        "label-bold":["14px",{lineHeight:"20px",fontWeight:"700"}],
        "headline-lg":["48px",{lineHeight:"56px",letterSpacing:"-0.02em",fontWeight:"700"}],
        "body-md":["16px",{lineHeight:"24px",fontWeight:"400"}],
        "display-xl":["80px",{lineHeight:"88px",letterSpacing:"-0.04em",fontWeight:"800"}],
        "title-md":["24px",{lineHeight:"32px",fontWeight:"600"}],
        "caption":["12px",{lineHeight:"16px",fontWeight:"500"}],
        "body-lg":["18px",{lineHeight:"28px",fontWeight:"400"}]
      }
    }}
  }
</script>
<style>
  .glass-panel { background: rgba(255,255,255,.7); backdrop-filter: blur(10px); -webkit-backdrop-filter: blur(10px); }
  .shadow-ambient-lvl1 { box-shadow: 0 10px 30px rgba(0,0,0,.05); }
  .btn-primary-vibe { background-color:#ccff00; color:#000; font-weight:800; transition:all .3s ease; }
  .btn-primary-vibe:hover { background-color:#e4006c; color:#fff; }
  .btn-secondary-vibe { background:transparent; border:2px solid #1a1c1c; color:#1a1c1c; font-weight:700; transition:all .3s ease; }
  .btn-secondary-vibe:hover { background:#1a1c1c; color:#fff; }
  .input-vibe { border:2px solid #1a1c1c; transition:all .2s ease; }
  .input-vibe:focus { outline:none; border-color:#e4006c; box-shadow:0 0 0 4px rgba(228,0,108,.2); }
  .nav-link-vibe { position:relative; }
  .nav-link-vibe::after { content:''; position:absolute; width:0; height:4px; bottom:-4px; left:0;
                          background-color:#ccff00; transition:width .3s ease; }
  .nav-link-vibe:hover::after { width:100%; }
  .product-card-vibe { transition: transform .3s ease, box-shadow .3s ease; }
  .product-card-vibe:hover { transform: translateY(-4px) scale(1.02); box-shadow:0 15px 40px rgba(0,0,0,.1); }
  .product-card-image-vibe { transition: transform .5s ease; }
  .product-card-vibe:hover .product-card-image-vibe { transform: scale(1.05); }
  .quick-add-overlay { opacity:0; transform: translateY(10px); transition: all .3s ease; }
  .product-card-vibe:hover .quick-add-overlay { opacity:1; transform: translateY(0); }
  /* Thanh quản trị WordPress cao 32px — đẩy header dính xuống cho khỏi bị che */
  body.admin-bar header.vibe-nav { top: 32px; }
</style>
<?php wp_head(); ?>
</head>

<body <?php body_class('bg-background text-on-background font-body-md text-body-md antialiased overflow-x-hidden selection:bg-primary-container selection:text-on-primary-fixed'); ?>>

<!-- Thanh điều hướng -->
<header class="vibe-nav w-full top-0 sticky z-50 bg-background border-b-4 border-primary">
  <div class="flex justify-between items-center px-gutter max-w-container-max mx-auto h-20">
    <a class="font-headline-lg text-headline-lg font-black tracking-tighter text-primary hover:opacity-80 transition-opacity"
       href="<?php echo esc_url(home_url('/')); ?>">VIBE</a>

    <nav class="hidden md:flex items-center gap-lg">
      <a class="nav-link-vibe text-on-background font-body-md text-body-md hover:text-secondary transition-colors duration-200"
         href="<?php echo esc_url(home_url('/')); ?>">Trang Chủ</a>
      <a class="text-primary font-bold border-b-4 border-primary pb-1 font-body-md text-body-md" href="#">Bộ Sưu Tập</a>
      <a class="nav-link-vibe text-on-background font-body-md text-body-md hover:text-secondary transition-colors duration-200" href="#mix-match">Xu Hướng</a>
      <a class="nav-link-vibe text-on-background font-body-md text-body-md hover:text-secondary transition-colors duration-200" href="#danh-gia">Đánh Giá</a>
    </nav>

    <div class="flex items-center gap-sm">
      <button class="p-2 text-primary hover:text-secondary transition-colors duration-200 scale-105 hover:scale-110">
        <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 0;">person</span>
      </button>
      <button class="p-2 text-primary hover:text-secondary transition-colors duration-200 scale-105 hover:scale-110 relative">
        <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 0;">shopping_bag</span>
        <span class="absolute top-1 right-1 flex h-3 w-3">
          <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-secondary-container opacity-75"></span>
          <span class="relative inline-flex rounded-full h-3 w-3 bg-secondary-container"></span>
        </span>
      </button>
    </div>
  </div>
</header>

<main class="w-full">

  <!-- Đường dẫn phân cấp -->
  <div class="max-w-container-max mx-auto px-gutter py-md">
    <nav class="flex text-on-surface-variant font-caption text-caption uppercase tracking-wider gap-xs items-center">
      <a class="hover:text-primary transition-colors" href="<?php echo esc_url(home_url('/')); ?>">VIBE</a>
      <span class="material-symbols-outlined text-[16px]">chevron_right</span>
      <a class="hover:text-primary transition-colors" href="#">Bộ Sưu Tập</a>
      <span class="material-symbols-outlined text-[16px]">chevron_right</span>
      <span class="font-bold text-on-background">Áo Hoodie Oversize Phong Cách</span>
    </nav>
  </div>

  <!-- Chi tiết sản phẩm -->
  <section class="max-w-container-max mx-auto px-gutter grid grid-cols-1 md:grid-cols-12 gap-xl md:gap-lg mb-xl items-start">

    <!-- Cột trái: thư viện ảnh -->
    <div class="md:col-span-7 flex flex-col gap-sm">
      <div class="relative w-full aspect-[4/5] bg-surface-container rounded-xl overflow-hidden shadow-ambient-lvl1">
        <img class="w-full h-full object-cover" alt="Người mẫu mặc áo hoodie oversize trong bối cảnh đô thị"
             src="https://lh3.googleusercontent.com/aida-public/AB6AXuAKT4BfeyZiCRU9CIaSUQrQNgMZaO083nYsRz8X1C2VCCpB0erPTptZIBj9GJpbXySpnK8p0VzWipm7hY-YcOnHc6Q6hv19_ISVH4ATtd_6zmKfK1y0rA9fspMEbRQT0L8CNWGkxGNn7riTorzYpPSpgn_JAkSHN5FeT9BeGs2NQ63_l5iSqJc3drZvBFr2zZHZUP_gpEPmIOucnnJfpGOHolHlNECbU54o2eGb44ZdVMK12Ae6Wg"/>
        <div class="absolute top-md left-md flex flex-col gap-xs">
          <span class="bg-secondary-container text-on-secondary px-sm py-xs font-label-bold text-label-bold uppercase tracking-wider rounded-sm">Mới Nhất</span>
          <span class="bg-on-background text-background px-sm py-xs font-label-bold text-label-bold uppercase tracking-wider rounded-sm">Hot Trend</span>
        </div>
      </div>

      <div class="grid grid-cols-4 gap-sm">
        <?php
        $k23_thumbs = [
          ['https://lh3.googleusercontent.com/aida-public/AB6AXuAJkRK6flDDsD-Mv2OxHrsukaAWsBycmaJ1PpZuWy3DcaYxh3V18ourAQ1w8IYf6b5d9bi4zYA823CgZ6pKglAHQK9BaQZyLO4ajhQZxTQFebTLdBqpphR6Mf_FMEKPgqFI73fjEONwwhGHJgIp5KAeLapf_yPA9Y5F3eQkDt-LcS-pdeYV_2LFU6fG0UvYZGTVQ4e63MlfYBrSWMDDvV2XnQHT4vgGmoZ9B44JN7ink1Y-I3L0Eg', 'Cận cảnh chất vải nỉ bông', true],
          ['https://lh3.googleusercontent.com/aida-public/AB6AXuCvfaRzsJl7mV-h0X0oM_a6-0gFFIvJ84-YnUCE8sLuL_nUeU-YpcoTNimFcW47rmpmrmufCXPnOc2ManszHa-23kI24QBVQ1gO7wKec3FLnc0mWUlwkt5yuFlaA2AtneCB-qpq_24jwffORVHy5Huf13x140v7Q6lqiiuwyRGMLlqg3tMk_uUa8OnqbcMTFF30lzO07CxwR5P9jv5YpWkokhe6y6cgj7zVH1TXPvwROSUzCbClbQ', 'Mặt sau chiếc áo', false],
          ['https://lh3.googleusercontent.com/aida-public/AB6AXuC1VZQMWi4eiHKljQvo1JG6Lci56jCYW4F21OLoACoSyXjuyMPneeH4y6ZaaRmsv1_pUSJcEmNikdpmRvSoApGu0Zo8n2xG_fGNiTV-M6LtAOAONW2RCalb-FAp68vyr1nqBTGQK2AIFZBAPmg1bkXjzqjUbYAd6IaB_h6cpnZZVSYfhWmV_qx2Gt4qfa9yymp9rTfgsz8UnUatuaplsWifX8D08wgoLDCw_8mL9e7uzDh5idEnvw', 'Chi tiết mũ và dây rút', false],
          ['https://lh3.googleusercontent.com/aida-public/AB6AXuAb6ZpsKw07u3mlsfxF895ctwyWUU4pc6cmg8FvHT9DK5_fn26nzbWTPhmOQMOJUBWHrLU71JRA3x-dqhhmfIXWSXmVOMkQGo1YbjPNOKiPVAuAxofvMOffFOV4A0EEPmi_pOKoNKI7CXTRR_7s6fdvh0Tptuci1R8LVkA0weu42UK0W0hazsoywuAW9ZTSUjc8tUd9L8W2P5yoa5YwwuRvoGWqD-iY-Fp0nQ2lwB_6YcR5JYhfCA', 'Ảnh phong cách tại skatepark', false],
        ];
        foreach ($k23_thumbs as $i => $th) : ?>
          <button class="aspect-square bg-surface-container rounded-lg overflow-hidden border-2 <?php echo $th[2] ? 'border-primary-container' : 'border-transparent hover:border-outline-variant'; ?> transition-colors relative">
            <img class="w-full h-full object-cover <?php echo $i === 3 ? 'opacity-70' : ''; ?>"
                 alt="<?php echo esc_attr($th[1]); ?>" src="<?php echo esc_url($th[0]); ?>"/>
            <?php if ($i === 3) : ?>
              <span class="absolute inset-0 m-auto w-8 h-8 material-symbols-outlined text-on-background bg-background rounded-full p-1 shadow-ambient-lvl1" style="font-variation-settings:'FILL' 1;">play_arrow</span>
            <?php endif; ?>
          </button>
        <?php endforeach; ?>
      </div>
    </div>

    <!-- Cột phải: thông tin sản phẩm -->
    <div class="md:col-span-5 flex flex-col md:sticky md:top-28">
      <h1 class="font-headline-lg-mobile md:font-headline-lg text-headline-lg-mobile md:text-headline-lg font-black tracking-tighter text-on-background mb-xs uppercase">
        Áo Hoodie Oversize Phong Cách
      </h1>

      <div class="flex items-center gap-sm mb-md">
        <span class="font-title-md text-title-md font-bold text-primary">850,000đ</span>
        <span class="font-body-md text-body-md text-on-surface-variant line-through">1,200,000đ</span>
      </div>

      <p class="font-body-lg text-body-lg text-on-surface-variant mb-lg border-b-2 border-surface-variant pb-md">
        Chiếc hoodie định hình phong cách đường phố thế hệ mới. Form dáng oversize cực rộng, chất vải nỉ bông
        dày dặn đứng form, sẵn sàng cho mọi outfit nổi loạn nhất của bạn.
      </p>

      <div class="mb-md">
        <h3 class="font-label-bold text-label-bold text-on-background uppercase tracking-wider mb-sm">Màu sắc: Đen Than</h3>
        <div class="flex gap-sm">
          <?php foreach (['#1A1A1A' => true, '#E4006C' => false, '#CCFF00' => false] as $mau => $chon) : ?>
            <label class="relative cursor-pointer">
              <input <?php checked($chon); ?> class="peer sr-only" name="color" type="radio"/>
              <div class="w-10 h-10 rounded-full border-2 border-transparent peer-checked:border-primary-container peer-checked:ring-2 peer-checked:ring-primary-container ring-offset-2 transition-all"
                   style="background-color: <?php echo esc_attr($mau); ?>"></div>
            </label>
          <?php endforeach; ?>
        </div>
      </div>

      <div class="mb-lg">
        <div class="flex justify-between items-center mb-sm">
          <h3 class="font-label-bold text-label-bold text-on-background uppercase tracking-wider">Kích thước</h3>
          <a class="font-caption text-caption text-secondary font-bold hover:underline decoration-2 underline-offset-2" href="#">Hướng dẫn chọn size</a>
        </div>
        <div class="grid grid-cols-4 gap-sm">
          <?php foreach ([['S', false, false], ['M', true, false], ['L', false, false], ['XL', false, true]] as $sz) : ?>
            <label class="cursor-pointer">
              <input <?php checked($sz[1]); ?> class="peer sr-only" name="size" type="radio" <?php disabled($sz[2]); ?>/>
              <div class="py-sm text-center border-2 border-on-background font-label-bold text-label-bold peer-checked:bg-on-background peer-checked:text-background hover:bg-surface-variant transition-colors uppercase <?php echo $sz[2] ? 'opacity-50 cursor-not-allowed' : ''; ?>">
                <?php echo esc_html($sz[0]); ?>
              </div>
              <?php if ($sz[2]) : ?><span class="sr-only">Hết hàng</span><?php endif; ?>
            </label>
          <?php endforeach; ?>
        </div>
      </div>

      <div class="flex flex-col gap-sm mb-lg">
        <div class="flex gap-sm">
          <div class="flex items-center border-2 border-on-background h-14 w-32 justify-between px-xs">
            <button class="p-2 hover:bg-surface-variant transition-colors"><span class="material-symbols-outlined text-[20px]">remove</span></button>
            <span class="font-label-bold text-label-bold">1</span>
            <button class="p-2 hover:bg-surface-variant transition-colors"><span class="material-symbols-outlined text-[20px]">add</span></button>
          </div>
          <button class="flex-1 btn-primary-vibe h-14 flex items-center justify-center font-label-bold text-label-bold uppercase tracking-wider text-lg">
            Thêm Vào Giỏ
          </button>
        </div>
        <button class="w-full btn-secondary-vibe h-14 flex items-center justify-center gap-xs font-label-bold text-label-bold uppercase tracking-wider">
          <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 0;">favorite</span>
          Yêu Thích Gấp
        </button>
      </div>

      <ul class="flex flex-col gap-sm font-caption text-caption text-on-surface-variant bg-surface-container-low p-md rounded-lg shadow-ambient-lvl1 border border-surface-variant">
        <li class="flex items-center gap-sm"><span class="material-symbols-outlined text-primary">local_shipping</span>Freeship cho đơn hàng từ 500k.</li>
        <li class="flex items-center gap-sm"><span class="material-symbols-outlined text-primary">replay</span>Đổi trả linh hoạt trong 7 ngày (chưa cắt tag).</li>
        <li class="flex items-center gap-sm"><span class="material-symbols-outlined text-primary">verified</span>Cam kết chính hãng VIBE 100%.</li>
      </ul>
    </div>
  </section>

  <div class="max-w-container-max mx-auto px-gutter py-md"><hr class="border-t-2 border-surface-variant"/></div>

  <!-- Mô tả và đánh giá -->
  <section id="danh-gia" class="max-w-container-max mx-auto px-gutter grid grid-cols-1 md:grid-cols-2 gap-xl mb-xl scroll-mt-28">
    <div class="flex flex-col gap-md">
      <h2 class="font-title-md text-title-md font-bold text-on-background uppercase tracking-tight flex items-center gap-sm">
        <span class="w-8 h-8 bg-primary-container text-on-primary-fixed flex items-center justify-center rounded-sm material-symbols-outlined">info</span>
        Chi Tiết Sản Phẩm
      </h2>
      <div class="max-w-none font-body-md text-body-md text-on-surface-variant space-y-sm">
        <p>Thiết kế không dành cho những ai thích sự an toàn. Áo Hoodie Oversize VIBE mang đến diện mạo cool ngầu với form dáng thả lỏng tối đa, che khuyết điểm cực tốt và tạo hiệu ứng layer xuất sắc.</p>
        <ul class="list-disc pl-5 space-y-xs">
          <li><strong>Chất liệu:</strong> Nỉ bông French Terry cao cấp, định lượng 350gsm. Dày, đứng form, không xù lông.</li>
          <li><strong>Chi tiết:</strong> Mũ trùm sâu hai lớp, dây rút kim loại chống rỉ, túi kangaroo rộng rãi phía trước.</li>
          <li><strong>Họa tiết:</strong> Thêu logo 3D nổi bật ở ngực trái, kỹ thuật thêu sắc nét.</li>
          <li><strong>Sản xuất:</strong> Thiết kế và sản xuất tại Việt Nam.</li>
        </ul>
      </div>
    </div>

    <div class="flex flex-col gap-md">
      <h2 class="font-title-md text-title-md font-bold text-on-background uppercase tracking-tight flex items-center gap-sm justify-between">
        <span class="flex items-center gap-sm">
          <span class="w-8 h-8 bg-secondary-container text-on-secondary flex items-center justify-center rounded-sm material-symbols-outlined">forum</span>
          Đánh Giá (4.8/5)
        </span>
        <button class="font-label-bold text-label-bold text-primary underline decoration-2 underline-offset-2 hover:text-secondary transition-colors">Xem tất cả</button>
      </h2>

      <div class="flex flex-col gap-sm">
        <?php
        $k23_reviews = [
          ['M', 'Minh Trí', 5, '2 ngày trước', 'Áo form siêu rộng mặc cực cháy luôn anh em. Chất vải xịn, giặt máy không bị nhão. Mua màu đen than dễ phối đồ lắm.', 'bg-tertiary-container text-on-tertiary-container'],
          ['L', 'Linh Phạm', 4, '1 tuần trước', 'Mình cao 1m60 mặc size S vẫn trùm mông rộng rãi đúng ý. Màu neon ở ngoài nổi bần bật. Trừ 1 sao vì giao hàng hơi lâu.', 'bg-primary-container text-on-primary-fixed'],
        ];
        foreach ($k23_reviews as $rv) : ?>
          <div class="bg-surface p-md rounded-xl border border-surface-variant shadow-ambient-lvl1">
            <div class="flex justify-between items-start mb-sm">
              <div class="flex items-center gap-sm">
                <div class="w-10 h-10 rounded-full flex items-center justify-center font-bold <?php echo esc_attr($rv[5]); ?>"><?php echo esc_html($rv[0]); ?></div>
                <div>
                  <h4 class="font-label-bold text-label-bold"><?php echo esc_html($rv[1]); ?></h4>
                  <div class="flex text-primary-container text-[16px]">
                    <?php for ($i = 1; $i <= 5; $i++) : ?>
                      <span class="material-symbols-outlined <?php echo $i > $rv[2] ? 'text-outline' : ''; ?>" style="font-variation-settings:'FILL' 1;">star</span>
                    <?php endfor; ?>
                  </div>
                </div>
              </div>
              <span class="font-caption text-caption text-outline"><?php echo esc_html($rv[3]); ?></span>
            </div>
            <p class="font-body-md text-body-md text-on-surface"><?php echo esc_html($rv[4]); ?></p>
          </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>

  <!-- Sản phẩm liên quan -->
  <section id="mix-match" class="max-w-container-max mx-auto px-gutter py-xl bg-surface-container-low rounded-t-[3rem] mt-xl scroll-mt-28">
    <div class="text-center mb-lg">
      <h2 class="font-display-xl text-[48px] leading-[56px] md:text-display-xl font-black uppercase tracking-tighter text-on-background">Mix &amp; Match</h2>
      <p class="font-body-lg text-body-lg text-on-surface-variant mt-sm">Hoàn thiện outfit của bạn với những item cực cháy này.</p>
    </div>

    <div class="grid grid-cols-2 md:grid-cols-4 gap-sm md:gap-md">
      <?php
      $k23_products = [
        ['Quần Đáy Thụng', 'Quần Cargo Parachute', '650,000đ', '', '', 'https://lh3.googleusercontent.com/aida-public/AB6AXuC2HdL6SYaEAYRGzbSu7O988YckIXHhdYGGmwpZXg3uHqnUx7LiAlJXW9Pev4jM0GWAN5_nRiuNiYptP3QuANNkF2iVMPMxW2kkibDqvkLf0PukwbhgUfdeQh9EH8TELPfdOv0k0e4xMgY4yabzpTnYQoAArNU54aIUJeExeLXjNte9uDRwl7Vb4ubp-okLbSn9gJyzkJTvfGBVYErYhgJIqqrHINUq-Rq5yPm-0oxX95XB63aynw', false],
        ['Giày Sneaker', 'Giày Chunky V-Max', '950,000đ', '1,200,000đ', '-20%', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBlLUo1HutpWdqCoikhcQjKCRyRc6Yw6iRgxMX88dPCTO_e9CiUljbbqn2zBl3CiU7xdTr5KZOwX3biwMeczF1S6hHtpvgl_0FA4B9aD3roWHp84X52aRekPEYyDaEXboDnQpEzmALOCF2snn7iFEraYZoCx0AP82z9B6YHX8tPAm6QNLIprkgQoyeeta56jB0-dWYfgmCeLVCbAUr73ak2CgpYhfl-uXfFjHmf-zGGsNHJMpQ9qw', false],
        ['Phụ Kiện', 'Mũ Lưỡi Trai Distressed', '250,000đ', '', '', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAqKgZ960p0U2j4sax78YOz7Yq5AQTlR93cKBigx3a7jLu6Ozl8o9fc1G57xi06JP0u9CxrFzkmDMPk-7LrGIfF5GRMCRZUXds6N7Xy_OvukmDQaPD5NtzpB3hFuGAJO06TFsfsz7cRPUkmr3KJZyv4GXkpZ9tDuDZSgQUst7Wht9Z3G2SIDoc3HBTHj8fr0g4Gsaddvgps4XJqIPrdc0PHiba8AdEPFa2r9DTXjBGb7qeFSMMAWA', true],
        ['Trang Sức', 'Dây Chuyền Cuban V-Link', '380,000đ', '', '', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBa-dhf-m8mh4LuhMt0keH0iGAsdM-f-yX0SOQFiMzALgaukleHzTfDGeUBN5GVRplDGCt3HiKWmrikmVFV3TH4uT5-9UjIriGsY68TF831Z25sPCnZef0xDq0o0PbJy8m8y7V-onxtUlzZPCufzSBWfUsiCUwvSFejgC9fgUioty1L46jCSw1mRlu5jYWeq9cJ_86zL3c4i1UgRY1YqM9tuvgiEezTAqeLMIRzWoOS0qAUT2z56g', true],
      ];
      foreach ($k23_products as $sp) : ?>
        <div class="product-card-vibe group relative flex-col gap-sm <?php echo $sp[6] ? 'hidden md:flex' : 'flex'; ?>">
          <div class="relative w-full aspect-[3/4] rounded-xl overflow-hidden bg-surface">
            <img class="product-card-image-vibe w-full h-full object-cover" alt="<?php echo esc_attr($sp[1]); ?>" src="<?php echo esc_url($sp[5]); ?>"/>
            <?php if ($sp[4]) : ?>
              <div class="absolute top-sm right-sm z-10">
                <span class="bg-secondary-container text-on-secondary px-2 py-1 font-caption text-[10px] uppercase font-bold rounded-sm"><?php echo esc_html($sp[4]); ?></span>
              </div>
            <?php endif; ?>
            <div class="absolute bottom-0 left-0 w-full p-sm quick-add-overlay z-10">
              <button class="w-full py-sm glass-panel font-label-bold text-label-bold uppercase tracking-wider rounded-lg border border-white/20 hover:bg-white/90 hover:text-black transition-colors">+ Thêm Nhanh</button>
            </div>
          </div>
          <div class="flex flex-col">
            <span class="font-caption text-caption text-outline uppercase tracking-wider mb-xs"><?php echo esc_html($sp[0]); ?></span>
            <h3 class="font-title-md text-[18px] leading-[24px] md:text-title-md font-bold text-on-background line-clamp-1"><?php echo esc_html($sp[1]); ?></h3>
            <div class="flex gap-sm items-center mt-xs">
              <span class="font-body-md text-body-md font-bold <?php echo $sp[3] ? 'text-secondary' : 'text-primary'; ?>"><?php echo esc_html($sp[2]); ?></span>
              <?php if ($sp[3]) : ?><span class="font-caption text-caption line-through text-outline"><?php echo esc_html($sp[3]); ?></span><?php endif; ?>
            </div>
          </div>
        </div>
      <?php endforeach; ?>
    </div>
  </section>

  <!-- Nội dung soạn trong trang WordPress, nếu có -->
  <?php if (have_posts()) : while (have_posts()) : the_post();
      if (trim(get_the_content()) !== '') : ?>
        <section class="max-w-container-max mx-auto px-gutter py-xl">
          <div class="bg-surface p-md rounded-xl border border-surface-variant shadow-ambient-lvl1">
            <?php the_content(); ?>
          </div>
        </section>
      <?php endif;
  endwhile; endif; ?>

</main>

<footer class="w-full mt-xl bg-surface-container-highest">
  <div class="grid grid-cols-1 md:grid-cols-4 gap-md px-gutter py-xl max-w-container-max mx-auto">
    <div class="flex flex-col gap-sm md:col-span-1">
      <div class="font-headline-lg-mobile text-headline-lg-mobile font-bold text-primary">VIBE</div>
      <p class="font-body-md text-body-md text-secondary mt-2">
        © <?php echo esc_html(date('Y')); ?> <?php echo esc_html(get_bloginfo('name')); ?> — Thiết kế cho thế hệ Gen Z.
      </p>
    </div>

    <div class="flex flex-col gap-sm">
      <h4 class="font-label-bold text-label-bold text-on-background uppercase tracking-wider mb-sm">Khám Phá</h4>
      <a class="font-body-md text-body-md text-on-surface-variant hover:underline decoration-primary decoration-4 opacity-80 hover:opacity-100 transition-opacity" href="<?php echo esc_url(home_url('/')); ?>">Về Trang Chủ</a>
      <a class="font-body-md text-body-md text-on-surface-variant hover:underline decoration-primary decoration-4 opacity-80 hover:opacity-100 transition-opacity" href="#">Chính Sách Đổi Trả</a>
    </div>

    <div class="flex flex-col gap-sm">
      <h4 class="font-label-bold text-label-bold text-on-background uppercase tracking-wider mb-sm">Phiên Bản Đang Chạy</h4>
      <span class="font-caption text-caption text-on-surface-variant">Theme K23 v<?php echo esc_html($k23_ver); ?></span>
      <span class="font-caption text-caption text-secondary font-bold"><?php echo esc_html($k23_commit); ?></span>
      <span class="font-caption text-caption text-outline">Máy chủ: <?php echo esc_html(gethostname()); ?></span>
      <span class="font-caption text-caption text-outline">Tải lúc: <?php echo esc_html(date('H:i:s d/m/Y')); ?></span>
    </div>

    <div class="flex flex-col gap-sm">
      <h4 class="font-label-bold text-label-bold text-on-background uppercase tracking-wider mb-sm">Đăng Ký Bản Tin</h4>
      <p class="font-caption text-caption text-on-surface-variant mb-xs">Nhận thông báo về drop mới và deal sốc.</p>
      <div class="flex gap-xs">
        <input class="input-vibe flex-1 bg-surface-container-lowest px-sm py-xs font-body-md text-body-md rounded-sm" placeholder="Email của bạn..." type="email"/>
        <button class="bg-primary text-on-primary font-bold px-md py-xs rounded-sm hover:bg-primary-container hover:text-on-primary-fixed transition-colors">GỬI</button>
      </div>
    </div>
  </div>
</footer>

<?php wp_footer(); ?>
</body>
</html>

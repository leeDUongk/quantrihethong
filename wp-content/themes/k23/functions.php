<?php
/**
 * Theme K23 — cấu hình cơ bản.
 * Hằng số K23_VERSION và K23_LAN_SUA là hai giá trị dùng để minh họa trong lớp:
 * đổi chúng rồi push lên GitHub, kéo về máy ảo, tải lại trang là thấy đổi ngay.
 */

define('K23_VERSION',  '1.0.0');
define('K23_LAN_SUA',  'Sua lan 1 - doi mau chu dao');
define('K23_MAU_NEN',  '#C0392B');
define('K23_REPO',     'github.com/<tai-khoan-github>/quantrihethong-<MSSV>');

// Lời chào hiển thị trên trang Portfolio DevOps.
// Đây là hằng số dễ sửa nhất để minh họa chuỗi: sửa ở đây -> push -> pull -> tải lại trang.
define('K23_LOI_CHAO', 'Xin chào K23K!');

function k23_setup() {
    add_theme_support('title-tag');
    add_theme_support('post-thumbnails');
    register_nav_menus(['chinh' => 'Menu chính']);
}
add_action('after_setup_theme', 'k23_setup');

function k23_assets() {
    wp_enqueue_style('k23-style', get_stylesheet_uri(), [], K23_VERSION);
    // Cho phép đổi màu chủ đạo chỉ bằng một hằng số ở trên
    wp_add_inline_style('k23-style', ':root{--mau-chinh:' . K23_MAU_NEN . ';}');
}
add_action('wp_enqueue_scripts', 'k23_assets');

/**
 * Tìm trang đang dùng mẫu "Portfolio DevOps".
 * Trả về đường dẫn nếu có, chuỗi rỗng nếu chưa tạo trang nào.
 */
function k23_link_portfolio() {
    $tim = get_pages([
        'meta_key'   => '_wp_page_template',
        'meta_value' => 'page-portfolio.php',
        'number'     => 1,
    ]);
    return $tim ? get_permalink($tim[0]->ID) : '';
}

/** Bảng thông tin phiên bản hiển thị trên đầu mọi trang — trái tim của bài demo. */
function k23_bang_phien_ban() {
    $commit = trim(@file_get_contents(get_template_directory() . '/COMMIT.txt'));
    if ($commit === '') { $commit = 'khong ro'; }
    echo '<div class="bang-phien-ban">';
    echo '<span>Theme K23 <b>v' . esc_html(K23_VERSION) . '</b></span>';
    echo '<span>Lần sửa: <b>' . esc_html(K23_LAN_SUA) . '</b></span>';
    echo '<span>Commit: <b>' . esc_html($commit) . '</b></span>';
    echo '<span>Máy chủ: <b>' . esc_html(gethostname()) . '</b></span>';
    echo '<span>Tải lúc: <b>' . esc_html(date('H:i:s d/m/Y')) . '</b></span>';
    echo '</div>';
}

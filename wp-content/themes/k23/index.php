<?php get_header(); ?>

<div class="hop-demo">
    <h3>Vòng đời triển khai đang chạy trước mắt</h3>
    <p>Nội dung trong hộp này nằm ở file <code>index.php</code> của theme K23, được lưu trên GitHub.
       Sửa trên máy tính → đẩy lên GitHub → máy chủ kéo về → tải lại trang là thấy đổi.</p>
    <p><b>Thông điệp hiện tại:</b> Xin chào lớp K23.</p>
</div>

<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
    <article class="the-bai">
        <h2><a href="<?php the_permalink(); ?>"><?php the_title(); ?></a></h2>
        <div class="ngay"><?php echo get_the_date('d/m/Y H:i'); ?></div>
        <div><?php the_excerpt(); ?></div>
    </article>
<?php endwhile; else : ?>
    <article class="the-bai">
        <h2>Chưa có bài viết nào</h2>
        <p>Vào trang quản trị để đăng bài đầu tiên.</p>
    </article>
<?php endif; ?>

<?php get_footer(); ?>

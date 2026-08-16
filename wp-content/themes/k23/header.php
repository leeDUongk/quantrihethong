<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
<?php k23_bang_phien_ban(); ?>
<header class="k23-header">
    <h1><a href="<?php echo esc_url(home_url('/')); ?>" style="text-decoration:none;color:inherit">
        <?php bloginfo('name'); ?></a></h1>
    <p><?php bloginfo('description'); ?></p>
</header>
<main>

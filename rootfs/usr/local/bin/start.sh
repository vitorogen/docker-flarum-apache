#!/bin/sh
set -e

# PHP config
sed -i "s/^memory_limit.*/memory_limit = $PHP_MEMORY_LIMIT/" $PHP_INI_DIR/php.ini
sed -i "s/^upload_max_filesize.*/upload_max_filesize = $UPLOAD_MAX_SIZE/" $PHP_INI_DIR/php.ini

# Flarum config
if [ -f "/var/www/html/forum/flarum/config.php" ]; then
  sed -i "s#'url' => '.*',#'url' => '$BASE_URL',#g" /var/www/html/forum/flarum/config.php
fi

apache2-foreground
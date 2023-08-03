FROM php:8.1-apache-bookworm

LABEL description="Forums made simple. Modern, fast, and free!" \
      maintainer="vitorogen <vitor.ogen@gmail.com>"

ARG VERSION=v1.8.0
ARG DEBIAN_FRONTEND=noninteractive

ENV UPLOAD_MAX_SIZE=5M \
    PHP_MEMORY_LIMIT=256M \
    COMPOSER_ALLOW_SUPERUSER=1 \
    BASE_URL=

RUN mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

# Flarum dependencies setup
RUN apt-get update \
    && apt install -y libzip-dev libpng-dev nano

RUN docker-php-ext-install zip
RUN docker-php-ext-install gd
RUN docker-php-ext-install pdo_mysql

# Composer setup
RUN curl -s https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Flarum setup
RUN mkdir -p /var/www/html/forum/flarum \
    && cd /var/www/html/forum/flarum \
    && COMPOSER_CACHE_DIR="/tmp" \
    && composer create-project flarum/flarum:$VERSION . --stability=beta \
    && composer install \
    && composer clear-cache \
    && rm -rf /flarum/.composer /tmp/*

# Reconfigure /flarum/public path to /forum
RUN mv /var/www/html/forum/flarum/public/* /var/www/html/forum/ \
    && mv /var/www/html/forum/flarum/public/.htaccess /var/www/html/forum/.htaccess \
    && ls -la /var/www/html/forum/flarum/public/ \
    # Uncomment .htaccess file lines 9 to 15
    && sed -i "9,15 s/^[[:space:]]*#//" /var/www/html/forum/.htaccess \
    # Customizing public path on site.php
    && sed -i "48c\    'public' => __DIR__.'/..'," /var/www/html/forum/flarum/site.php \
    # Updating site.php path on index.php
    && sed -i "10c\$site = require './flarum/site.php';" /var/www/html/forum/index.php

# Setup apache config file
COPY apache.conf /var/www/html/forum/flarum/apache.conf
# Create a symlink in the Apache directory to persist changes on the flarum volume
RUN ln -s /var/www/html/forum/flarum/apache.conf /etc/apache2/sites-available/flarum.conf

# Recommended permissions
RUN chown -R www-data:www-data /var/www/html/forum/ \
    && chmod -R 755 /var/www/html/forum/

RUN a2ensite flarum \
    && a2enmod rewrite

VOLUME /var/www/html/forum

COPY rootfs /
ENTRYPOINT ["/usr/local/bin/start.sh"]
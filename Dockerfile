FROM php:5.6-apache

# 安装必要的依赖
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libmcrypt-dev \
    libcurl4-openssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    pdo \
    pdo_mysql \
    zip \
    curl \
    mbstring \
    xml \
    json \
    && a2enmod rewrite

# 设置工作目录
WORKDIR /var/www/html

# 下载并解压 OwnCloud 7.0.2.1
RUN curl -L https://download.owncloud.org/community/owncloud-7.0.2.1.tar.bz2 | tar xj --strip-components=1

# 设置权限
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# 配置 PHP
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 512M/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/post_max_size = 8M/post_max_size = 512M/' "$PHP_INI_DIR/php.ini" \
    && sed -i 's/memory_limit = 128M/memory_limit = 512M/' "$PHP_INI_DIR/php.ini"

# 配置 Apache
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

EXPOSE 80 
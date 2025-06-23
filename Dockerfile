FROM php:5.6-apache

RUN echo "deb http://archive.debian.org/debian jessie main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security jessie/updates main contrib non-free" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid && \
    echo "Package: *\nPin: release n=jessie\nPin-Priority: 1001" > /etc/apt/preferences.d/00-jessie-archive

RUN apt-get update && \
    apt-get install -y --allow-unauthenticated --allow-downgrades --no-install-recommends \
        debian-archive-keyring \
        gnupg && \
    apt-get update && \
    apt-get install -y --allow-unauthenticated --allow-downgrades --no-install-recommends \
        zlib1g-dev=1:1.2.8.dfsg-2+deb8u1 \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libxml2-dev=2.9.1+dfsg1-5+deb8u8 \
        libzip-dev \
        zip unzip \
        libmcrypt4 libmcrypt-dev \
        libcurl4-openssl-dev=7.38.0-4+deb8u16 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd pdo pdo_mysql zip curl mbstring xml json mcrypt && \
    a2enmod rewrite

WORKDIR /var/www/html
RUN curl -L https://attic.owncloud.com/server/stable/owncloud-7.0.15.tar.bz2 | tar xj --strip-components=1 -C /var/www/html

RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 512M/' "$PHP_INI_DIR/php.ini" && \
    sed -i 's/post_max_size = .*/post_max_size = 512M/' "$PHP_INI_DIR/php.ini" && \
    sed -i 's/memory_limit = .*/memory_limit = 512M/' "$PHP_INI_DIR/php.ini"

COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

EXPOSE 80
CMD ["apache2-foreground"]

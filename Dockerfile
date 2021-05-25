# builder

FROM php:7.3-fpm-alpine as builder

ARG TAO_VERSION
ENV TAO_VERSION ${TAO_VERSION:-3.4-rc01}

# Install dependencies
RUN apk add --no-cache nodejs git npm

# Install composer
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/55e3ac0516cf01802649468315cd863bcd46a73f/web/installer -O - -q | php -- --quiet \
  && mv composer.phar /usr/local/bin/composer

RUN echo Downloading and installing TAO version "${TAO_VERSION}"

RUN curl -o tao.zip -LJO https://github.com/oat-sa/package-tao/archive/v${TAO_VERSION}.zip \
  && unzip -qq tao.zip -d /usr/src \
  && mv /usr/src/package-tao-${TAO_VERSION} /usr/src/tao \
  && composer self-update --1 \ 
  && composer config --global process-timeout 2000 \ 
  && composer install -d /usr/src/tao \
  && rm tao.zip

# runner

FROM php:7.3-fpm-alpine as runner

RUN apk update
RUN apk add --no-cache libpng-dev jpeg-dev postgresql-dev zip unzip sudo wget sqlite sqlite-dev zstd-dev libzip-dev mysql-client

RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/include/
RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd

RUN yes | pecl install igbinary redis

RUN docker-php-ext-install pdo_mysql mysqli pgsql pdo_pgsql gd opcache zip calendar
RUN docker-php-ext-enable igbinary redis

RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    echo 'opcache.load_comments=1'; \
} >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

COPY --from=builder /usr/src/tao /var/www/html
RUN chown -R www-data:www-data /var/www/html

RUN mkdir -p /var/lib/tao/data && chown www-data:www-data /var/lib/tao/data

VOLUME /var/lib/tao/data

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN env

CMD ["php-fpm"]
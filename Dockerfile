# builder

FROM composer:1.10 as builder

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
  && composer install -d /usr/src/tao \
  && rm tao.zip

# runner

FROM php:7.4.9-fpm-alpine3.12 as runner

RUN apk add --no-cache libpng-dev jpeg-dev postgresql-dev zip unzip sudo wget sqlite sqlite-dev zstd-dev libzip-dev

RUN docker-php-ext-configure gd --with-jpeg
RUN docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-configure mysqli --with-mysqli=mysqlnd

RUN yes | pecl install igbinary redis

RUN docker-php-ext-install pdo && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install pgsql && \
    docker-php-ext-install pdo_pgsql && \
    docker-php-ext-install pdo_sqlite && \
    docker-php-ext-install gd && \
    docker-php-ext-install opcache && \
    docker-php-ext-install zip && \
    docker-php-ext-install calendar && \
    docker-php-ext-enable igbinary && \
    docker-php-ext-enable redis

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

# Increase timeout to make sure installation works
RUN echo "max_execution_time = 300" > /usr/local/etc/php/php.ini
RUN mkdir -p /var/lib/tao/data && chown www-data:www-data /var/lib/tao/data

VOLUME /var/lib/tao/data

CMD ["php-fpm"]

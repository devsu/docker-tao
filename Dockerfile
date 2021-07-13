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

ARG FILE_PATH
ENV FILE_PATH ${FILE_PATH:-/var/lib/tao/data}

ENV DB_HOST ${DB_HOST:-localhost}
ENV DB_PORT ${DB_PORT:-3306}
ENV WAIT_HOSTS_TIMEOUT ${WAIT_HOSTS_TIMEOUT:-300}
ENV WAIT_SLEEP_INTERVAL ${WAIT_SLEEP_INTERVAL:-30}
ENV WAIT_HOST_CONNECT_TIMEOUT ${WAIT_HOST_CONNECT_TIMEOUT:-30}
ENV DB_DRIVER ${DB_DRIVER:-pdo_mysql}
ENV URL ${URL:-http://localhost}

RUN apk update
RUN apk add --no-cache libpng-dev jpeg-dev postgresql-dev zip unzip sudo wget sqlite sqlite-dev zstd-dev libzip-dev bash

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

RUN mkdir -p $FILE_PATH && chown www-data:www-data $FILE_PATH

VOLUME $FILE_PATH
VOLUME /var/www/html

ENV WAIT_VERSION 2.7.2
RUN curl -o wait -LJO https://github.com/ufoscout/docker-compose-wait/releases/download/$WAIT_VERSION/wait \
  && mv wait /wait \
  && chmod +x /wait

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["php-fpm"]
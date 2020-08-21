FROM composer:1.10

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

RUN chown -R www-data:www-data /usr/src/tao

ENTRYPOINT echo "tao was successfully built in /usr/src/tao." \
  && echo "You can use it by setting a volume, which should be shared with another container that run PHP applications."

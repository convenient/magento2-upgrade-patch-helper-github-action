FROM debian:buster-20240311-slim
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y jq libsodium-dev sed grep unzip zip wget lsb-release libsodium-dev libxslt1-dev build-essential libbz2-dev libfreetype6-dev libicu-dev libzip-dev libxslt-dev libtidy-dev libedit-dev libreadline-dev libonig-dev libjpeg-dev libpng-dev libcurl4-openssl-dev  libbz2-dev zlib1g zlib1g-dev sqlite3 libsqlite3-dev libssl-dev libxml2-dev pkg-config automake tree autotools-dev libtool build-essential curl git libedit-dev autoconf-archive

RUN git clone --single-branch --branch master https://github.com/phpenv/phpenv /root/.phpenv
RUN git clone https://github.com/php-build/php-build /root/.phpenv/plugins/php-build
RUN echo 'eval "$(phpenv init -)"' >> /root/.bashrc
ENV PATH="/root/.phpenv/bin:$PATH"

RUN source /root/.bashrc && phpenv install 7.2.34 && phpenv global 7.2.34 && sed -i 's/memory_limit = 128M/memory_limit = 1024M/' /root/.phpenv/versions/7.2.34/etc/php.ini && php --version
RUN source /root/.bashrc && PHP_BUILD_INSTALL_EXTENSION="libsodium=1.0.7" phpenv install 7.3.33 && phpenv global 7.3.33 && sed -i 's/memory_limit = 128M/memory_limit = 1024M/' /root/.phpenv/versions/7.3.33/etc/php.ini && php --version
RUN source /root/.bashrc && PHP_BUILD_INSTALL_EXTENSION="libsodium=1.0.7" phpenv install 7.4.33 && phpenv global 7.4.33 && sed -i 's/memory_limit = 128M/memory_limit = 1024M/' /root/.phpenv/versions/7.4.33/etc/php.ini && php --version
RUN source /root/.bashrc && PHP_BUILD_CONFIGURE_OPTS="--with-sodium" phpenv install 8.1.6  && phpenv global 8.1.6  && sed -i 's/memory_limit = 128M/memory_limit = 1024M/' /root/.phpenv/versions/8.1.6/etc/php.ini && php --version
RUN source /root/.bashrc && PHP_BUILD_CONFIGURE_OPTS="--with-sodium" phpenv install 8.2.16  && phpenv global 8.2.16  && sed -i 's/memory_limit = 128M/memory_limit = 1024M/' /root/.phpenv/versions/8.2.16/etc/php.ini && php --version
RUN source /root/.bashrc && PHP_BUILD_CONFIGURE_OPTS="--with-sodium" phpenv install 8.3.3  && phpenv global 8.3.3  && sed -i 's/memory_limit = 128M/memory_limit = 1024M/' /root/.phpenv/versions/8.3.3/etc/php.ini && php --version

RUN source /root/.bashrc && wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet && mv composer.phar /root/.phpenv/bin/composer2 && /root/.phpenv/bin/composer2 self-update --2
RUN source /root/.bashrc && wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet && mv composer.phar /root/.phpenv/bin/composer22 && /root/.phpenv/bin/composer2 self-update --2 && /root/.phpenv/bin/composer2 self-update --2.2
RUN source /root/.bashrc && wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet && mv composer.phar /root/.phpenv/bin/composer1 && /root/.phpenv/bin/composer1 self-update --1
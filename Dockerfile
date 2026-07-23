FROM alpine:latest

# Base image: plain Nginx. PHP-FPM is included but stays dormant unless
# the PHP_ENABLED variable is turned on at runtime (see entrypoint.sh).
RUN apk --update --no-cache add curl ca-certificates nginx \
    php83 \
    php83-fpm \
    php83-mbstring \
    php83-curl \
    php83-gd \
    php83-zip \
    php83-xml \
    php83-dom \
    php83-phar \
    php83-tokenizer \
    php83-ctype \
    php83-session \
    php83-fileinfo \
    php83-simplexml \
    php83-pdo \
    php83-pdo_mysql \
    php83-mysqli \
    php83-opcache \
    && ln -sf /usr/bin/php83 /usr/bin/php \
    && sed -i \
        -e "s/^user = .*/user = container/" \
        -e "s/^group = .*/group = container/" \
        -e "s/^listen = .*/listen = 127.0.0.1:9000/" \
        -e "s/^;\?listen.owner.*//" \
        -e "s/^;\?listen.group.*//" \
        -e "s/^;\?listen.mode.*//" \
        /etc/php83/php-fpm.d/www.conf \
    && sed -i \
        -e "s#^;\?pid = .*#pid = /tmp/php-fpm83.pid#" \
        -e "s#^;\?error_log = .*#error_log = /home/container/logs/php-fpm.log#" \
        /etc/php83/php-fpm.conf

RUN addgroup -g 988 container && adduser -D -u 988 -G container -h /home/container -s /bin/ash container

USER container
ENV  USER container
ENV HOME /home/container

WORKDIR /home/container
COPY ./entrypoint.sh /entrypoint.sh


CMD ["/bin/ash", "/entrypoint.sh"]

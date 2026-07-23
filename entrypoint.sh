#!/bin/ash
cd /home/container

PHP_INCLUDE="/tmp/nginx-php-location.conf"

if [ "${PHP_ENABLED}" = "1" ] || [ "${PHP_ENABLED}" = "true" ]; then
    echo "✓ PHP включен"
    cp /home/container/nginx/php-location.conf "$PHP_INCLUDE"
    php-fpm83 -D
else
    : > "$PHP_INCLUDE"
fi

echo "✓ Сервер запущен"
/usr/sbin/nginx -c /home/container/nginx/nginx.conf -p /home/container/

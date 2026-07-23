#!/bin/ash
cd /home/container

PHP_INCLUDE="/tmp/nginx-php-location.conf"
CF_RESTRICT="/tmp/nginx-cf-restrict.conf"

if [ "${PHP_ENABLED}" = "1" ] || [ "${PHP_ENABLED}" = "true" ]; then
    echo "✓ PHP включен"
    cp /home/container/nginx/php-location.conf "$PHP_INCLUDE"
    php-fpm83 -D
else
    : > "$PHP_INCLUDE"
fi

if [ "${CF_ONLY_MODE}" = "1" ] || [ "${CF_ONLY_MODE}" = "true" ]; then
    echo "✓ Режим \"только Cloudflare\" включен: прямой доступ по IP заблокирован"
    {
        echo "allow 127.0.0.1;"
        echo "allow ::1;"
        echo "deny all;"
    } > "$CF_RESTRICT"
else
    : > "$CF_RESTRICT"
fi

if [ -n "${CF_TUNNEL_TOKEN}" ]; then
    echo "✓ Запускаю Cloudflare Tunnel"
    cloudflared tunnel --no-autoupdate run --token "${CF_TUNNEL_TOKEN}" &
fi

echo "✓ Сервер запущен"
/usr/sbin/nginx -c /home/container/nginx/nginx.conf -p /home/container/

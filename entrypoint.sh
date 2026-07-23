#!/bin/ash
cd /home/container

PHP_INCLUDE="/tmp/nginx-php-location.conf"
LISTEN_CONF="/tmp/nginx-listen.conf"
PORT="${SERVER_PORT:-80}"

if [ "${PHP_ENABLED}" = "1" ] || [ "${PHP_ENABLED}" = "true" ]; then
    echo "✓ PHP включен"
    cp /home/container/nginx/php-location.conf "$PHP_INCLUDE"
    php-fpm83 -D
else
    : > "$PHP_INCLUDE"
fi

if [ "${CF_ONLY_MODE}" = "1" ] || [ "${CF_ONLY_MODE}" = "true" ]; then
    echo "✓ Режим \"только Cloudflare\" включен: порт ${PORT} закрыт снаружи, доступ только через локальный туннель"
    echo "listen 127.0.0.1:${PORT};" > "$LISTEN_CONF"
else
    echo "listen ${PORT};" > "$LISTEN_CONF"
fi

if [ -n "${CF_TUNNEL_TOKEN}" ]; then
    echo "✓ Запускаю Cloudflare Tunnel"
    cloudflared tunnel --no-autoupdate run --token "${CF_TUNNEL_TOKEN}" &
fi

echo "✓ Сервер запущен"
/usr/sbin/nginx -c /home/container/nginx/nginx.conf -p /home/container/

#!/bin/ash
cd /home/container

rm -rf /home/container/tmp/*
mkdir -p /home/container/tmp

CONF="/home/container/nginx/conf.d/default.conf"
PHP_BLOCK="/home/container/nginx/php-location.conf"
PHP_BLOCK_BUILT="/home/container/tmp/php-location-built.conf"

# The ##PHP_LOCATION_BLOCK## line is a comment (nginx ignores it) that acts
# as a permanent anchor. Any previously injected block between the
# START/END markers is stripped first so the toggle works both ways.
sed -i "/^##PHP_LOCATION_START##$/,/^##PHP_LOCATION_END##$/d" "$CONF"

if [ "${PHP_ENABLED}" = "1" ] || [ "${PHP_ENABLED}" = "true" ]; then
    echo "✓ PHP включен"
    {
        echo "##PHP_LOCATION_START##"
        cat "$PHP_BLOCK"
        echo "##PHP_LOCATION_END##"
    } > "$PHP_BLOCK_BUILT"
    sed -i "/^[[:space:]]*##PHP_LOCATION_BLOCK##[[:space:]]*$/r ${PHP_BLOCK_BUILT}" "$CONF"
    php-fpm83 -D
fi

echo "✓ Сервер запущен"
/usr/sbin/nginx -c /home/container/nginx/nginx.conf -p /home/container/

#!/bin/sh

set -eu

WP_PATH="/var/www/html"

: "${DOMAIN_NAME:?DOMAIN_NAME is required}"
: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${WP_TITLE:?WP_TITLE is required}"
: "${WP_ADMIN_USER:?WP_ADMIN_USER is required}"
: "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL is required}"
: "${WP_USER:?WP_USER is required}"
: "${WP_USER_EMAIL:?WP_USER_EMAIL is required}"

case "$(printf '%s' "$WP_ADMIN_USER" | tr '[:upper:]' '[:lower:]')" in
    *admin*)
        echo "WordPress administrator username must not contain admin" >&2
        exit 1
        ;;
esac

export WORDPRESS_DB_PASSWORD="$(cat /run/secrets/db_password)"

install -d -m 0755 -o www-data -g www-data "$WP_PATH"
install -d -m 0755 -o www-data -g www-data /run/php

if [ ! -f "$WP_PATH/wp-load.php" ]; then
    echo "Copying WordPress files into the persistent volume"
    cp -a /usr/src/wordpress/. "$WP_PATH/"
fi

if [ ! -d "$WP_PATH/wp-content/plugins/redis-cache" ]; then
    echo "Copying Redis Object Cache plugin"

    install -d -m 0755 -o www-data -g www-data \
        "$WP_PATH/wp-content/plugins"

    cp -a \
        /usr/src/wordpress/wp-content/plugins/redis-cache \
        "$WP_PATH/wp-content/plugins/"
fi

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Creating WordPress configuration"

    wp config create \
        --allow-root \
        --path="$WP_PATH" \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass=temporary-placeholder \
        --dbhost=mariadb:3306 \
        --skip-check

    wp config set FS_METHOD direct \
        --allow-root \
        --path="$WP_PATH" \
        --type=constant
fi

wp config set DB_PASSWORD \
    "getenv('WORDPRESS_DB_PASSWORD')" \
    --allow-root \
    --path="$WP_PATH" \
    --type=constant \
    --raw

echo "Waiting for MariaDB"

ATTEMPT=0

until php -r '
    $db = new mysqli(
        "mariadb",
        getenv("MYSQL_USER"),
        trim(file_get_contents("/run/secrets/db_password")),
        getenv("MYSQL_DATABASE")
    );
    exit($db->connect_errno ? 1 : 0);
'; do
    ATTEMPT=$((ATTEMPT + 1))

    if [ "$ATTEMPT" -ge 30 ]; then
        echo "MariaDB was not ready after 30 attempts" >&2
        exit 1
    fi

    sleep 2
done

if ! wp core is-installed \
    --allow-root \
    --path="$WP_PATH" \
    --url="https://${DOMAIN_NAME}"; then

    echo "Installing WordPress"

    wp core install \
        --allow-root \
        --path="$WP_PATH" \
        --url="https://${DOMAIN_NAME}" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$(cat /run/secrets/wp_admin_password)" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email
fi

if getent hosts redis >/dev/null 2>&1; then
    echo "Configuring Redis object cache"

    wp config set WP_REDIS_HOST redis \
        --allow-root \
        --path="$WP_PATH" \
        --type=constant

    wp config set WP_REDIS_PORT 6379 \
        --allow-root \
        --path="$WP_PATH" \
        --type=constant \
        --raw

    wp config set WP_REDIS_DATABASE 0 \
        --allow-root \
        --path="$WP_PATH" \
        --type=constant \
        --raw

    wp config set WP_REDIS_CLIENT phpredis \
        --allow-root \
        --path="$WP_PATH" \
        --type=constant

    if ! wp plugin is-active redis-cache \
        --allow-root \
        --path="$WP_PATH"; then

        wp plugin activate redis-cache \
            --allow-root \
            --path="$WP_PATH"
    fi

    wp redis enable \
        --allow-root \
        --path="$WP_PATH"

    echo "Redis object cache enabled"
else
    echo "Redis service not present; continuing without object cache"
fi

if ! wp user get "$WP_USER" \
    --allow-root \
    --path="$WP_PATH" \
    --url="https://${DOMAIN_NAME}" >/dev/null 2>&1; then

    echo "Creating regular WordPress user"

    wp user create \
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --allow-root \
        --path="$WP_PATH" \
        --url="https://${DOMAIN_NAME}" \
        --role=subscriber \
        --user_pass="$(cat /run/secrets/wp_user_password)"
fi

chown -R www-data:www-data "$WP_PATH"

echo "Starting PHP-FPM"
exec "$@"

#!/bin/sh

set -eu

WP_PATH="/var/www/html"

: "${FTP_USER:?FTP_USER is required}"

case "$FTP_USER" in
    *[!A-Za-z0-9_-]*|"")
        echo "Invalid FTP_USER value" >&2
        exit 1
        ;;
esac

FTP_PASSWORD="$(cat /run/secrets/ftp_password)"

if [ -z "$FTP_PASSWORD" ]; then
    echo "FTP password is empty" >&2
    exit 1
fi

install -d -m 0555 /var/run/vsftpd/empty
install -d -m 0775 -o www-data -g www-data "$WP_PATH"

if ! id "$FTP_USER" >/dev/null 2>&1; then
    useradd \
        --home-dir "$WP_PATH" \
        --no-create-home \
        --gid www-data \
        --shell /usr/sbin/nologin \
        "$FTP_USER"
fi

printf '%s:%s\n' "$FTP_USER" "$FTP_PASSWORD" | chpasswd

if ! grep -qxF /usr/sbin/nologin /etc/shells; then
    echo /usr/sbin/nologin >> /etc/shells
fi

chgrp -R www-data "$WP_PATH"
chmod -R g+rwX "$WP_PATH"

echo "Starting FTP server"
exec "$@"

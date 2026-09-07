#!/bin/sh

set -eu

: "${DOMAIN_NAME:?DOMAIN_NAME is required}"

case "$DOMAIN_NAME" in
    *[!A-Za-z0-9.-]*|"")
        echo "Invalid DOMAIN_NAME value" >&2
        exit 1
        ;;
esac

install -d -m 0700 /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/inception.crt ] \
    || [ ! -f /etc/nginx/ssl/inception.key ]; then

    echo "Generating self-signed TLS certificate for $DOMAIN_NAME"

    openssl req \
        -x509 \
        -nodes \
        -newkey rsa:2048 \
        -days 365 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=PT/ST=Lisbon/L=Lisbon/O=42/OU=Inception/CN=${DOMAIN_NAME}" \
        -addext "subjectAltName=DNS:${DOMAIN_NAME}"
fi

chmod 600 /etc/nginx/ssl/inception.key
chmod 644 /etc/nginx/ssl/inception.crt

sed "s/__DOMAIN_NAME__/${DOMAIN_NAME}/g" \
    /etc/nginx/templates/default.conf.template \
    > /etc/nginx/conf.d/default.conf

nginx -t

echo "Starting NGINX"
exec "$@"

#!/bin/sh

set -eu

DATADIR="/var/lib/mysql"
INIT_SQL="/run/mysqld/init.sql"

: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"

case "$MYSQL_DATABASE" in
    *[!A-Za-z0-9_]*|"")
        echo "Invalid MYSQL_DATABASE value" >&2
        exit 1
        ;;
esac

case "$MYSQL_USER" in
    *[!A-Za-z0-9_]*|"")
        echo "Invalid MYSQL_USER value" >&2
        exit 1
        ;;
esac

DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
DB_PASSWORD="$(cat /run/secrets/db_password)"

DB_ROOT_PASSWORD_SQL="$(printf '%s' "$DB_ROOT_PASSWORD" | sed -e 's/\\/\\\\/g' -e "s/'/''/g")"
DB_PASSWORD_SQL="$(printf '%s' "$DB_PASSWORD" | sed -e 's/\\/\\\\/g' -e "s/'/''/g")"

install -d -m 0755 -o mysql -g mysql /run/mysqld
chown -R mysql:mysql "$DATADIR"

if [ ! -d "$DATADIR/mysql" ]; then
    echo "Initializing MariaDB system tables"

    mariadb-install-db \
        --user=mysql \
        --datadir="$DATADIR" \
        --skip-test-db >/dev/null
fi

cat > "$INIT_SQL" <<SQL
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD_SQL}';
ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD_SQL}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD_SQL}';
FLUSH PRIVILEGES;
SQL

chown mysql:mysql "$INIT_SQL"
chmod 600 "$INIT_SQL"

echo "Starting MariaDB"
exec mariadbd --user=mysql --init-file="$INIT_SQL"

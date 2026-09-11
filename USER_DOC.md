# Inception User Documentation

## Services

The mandatory infrastructure provides:

- **NGINX:** receives HTTPS connections on port 443.
- **WordPress:** provides the website and administration panel.
- **MariaDB:** stores the WordPress database.

The bonus infrastructure provides:

- **Redis:** caches WordPress objects.
- **FTP:** provides file access to the WordPress volume.
- **Static website:** provides a separate simple website.
- **Adminer:** provides a graphical database administration interface.
- **cAdvisor:** displays container resource usage.

## Start the mandatory infrastructure

From the project root:

```bash
cd ~/inception
make
```

This builds and starts:

- MariaDB
- WordPress
- NGINX

## Start the bonus infrastructure

To start the mandatory and bonus services:

```bash
cd ~/inception
make bonus
```

## Check service status

```bash
make status
```

Running services should have the status `Up`.

## Access WordPress

Open:

```text
https://clumertz.42.fr
```

The project uses a self-signed TLS certificate. The browser may display a warning because the certificate is not signed by a public certificate authority.

## Access WordPress administration

Open:

```text
https://clumertz.42.fr/wp-admin/
```

Use:

```text
Username: value of WP_ADMIN_USER in srcs/.env
Password: content of secrets/wp_admin_password.txt
```

A regular WordPress user is also created using `WP_USER` and `wp_user_password.txt`.

## Access the static website

Open:

```text
http://127.0.0.1:8080
```

## Access Adminer

Open:

```text
http://127.0.0.1:8081
```

Use:

```text
System: MySQL
Server: mariadb
Username: value of MYSQL_USER in srcs/.env
Password: content of secrets/db_password.txt
Database: value of MYSQL_DATABASE in srcs/.env
```

The server must be `mariadb`, not `localhost`, because Adminer and MariaDB communicate through the Docker network.

## Access cAdvisor

Open:

```text
http://127.0.0.1:8090
```

cAdvisor displays CPU, memory, network, and filesystem information for the containers.

## Access FTP

Open the file manager and enter:

```text
ftp://127.0.0.1
```

Use:

```text
Username: value of FTP_USER in srcs/.env
Password: content of secrets/ftp_password.txt
```

The FTP server provides access to the WordPress volume.

## Test Redis

```bash
docker compose -f srcs/docker-compose.yml --profile bonus exec redis redis-cli ping
```

Expected output:

```text
PONG
```

## Credentials

Credentials are stored locally in secret files instead of directly in the Docker Compose file or `.env`. Docker mounts each required secret inside the appropriate container under `/run/secrets`. These files contain sensitive passwords, must have restricted permissions, and must never be committed to Git.

| File | Used by | Purpose |
|---|---|---|
| `secrets/db_root_password.txt` | MariaDB `root` user | Provides full administrative access to the MariaDB server. |
| `secrets/db_password.txt` | MariaDB `wpuser` user | Allows WordPress and Adminer to access the `wordpress` database. |
| `secrets/wp_admin_password.txt` | WordPress administrator | Allows the administrator to log in at `https://clumertz.42.fr/wp-admin/` and manage the website. |
| `secrets/wp_user_password.txt` | Regular WordPress user | Allows the non-administrator WordPress user to log in and use the website. |
| `secrets/ftp_password.txt` | FTP user | Allows the FTP user to access files stored in the WordPress volume. |

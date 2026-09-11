# Inception Developer Documentation

## Architecture

The mandatory request flow is:

```text
Browser
   |
   | HTTPS :443
   v
NGINX
   |
   | FastCGI :9000
   v
WordPress + PHP-FPM
   |
   | MariaDB protocol :3306
   v
MariaDB
```

Only NGINX publishes a mandatory host port. WordPress and MariaDB communicate through the internal Docker network.

## Prerequisites

The project must run inside a Linux virtual machine with:

- Docker Engine
- Docker Compose plugin
- GNU Make

Verify the required tools:

```bash
docker --version
docker compose version
make --version
```

## Clone the repository

```bash
git clone <repository-url> inception
cd inception
```

## Environment configuration

Create the local environment file:

```bash
cp srcs/.env.example srcs/.env
```

Edit it to update the login, domain, emails, and data path when using another virtual machine account.

The real `.env` file must not be committed to Git.

## Secrets

Create the secret files:

```bash
make secrets
```

Insert one non-empty password into each file:

```bash
nano secrets/db_root_password.txt
nano secrets/db_password.txt
nano secrets/wp_admin_password.txt
nano secrets/wp_user_password.txt
nano secrets/ftp_password.txt
```

Restrict their permissions:

```bash
chmod 600 secrets/*.txt
```

## Domain configuration

Edit:

```bash
sudo nano /etc/hosts
```

Add:

```text
127.0.0.1 clumertz.42.fr
```

## Build and start the mandatory part

```bash
make
```

This creates the data directories, builds the mandatory images, and starts:

- MariaDB
- WordPress
- NGINX

## Build and start the bonus part

```bash
make bonus
```

This starts the mandatory services and:

- Redis
- FTP
- Static website
- Adminer
- cAdvisor

## Makefile commands

Start the mandatory infrastructure:

```bash
make
```

Start mandatory and bonus services:

```bash
make bonus
```

Display running services:

```bash
make status
```

Display logs:

```bash
make logs
```

Stop containers:

```bash
make stop
```

Start stopped containers:

```bash
make start
```

Restart mandatory services:

```bash
make restart
```

Restart mandatory and bonus services:

```bash
make bonus-restart
```

Stop and remove containers:

```bash
make down
```

Clean project containers:

```bash
make clean
```

Remove containers, images, and Docker volume definitions:

```bash
make fclean
```

Rebuild the mandatory infrastructure:

```bash
make re
```

## Network

Display Docker networks:

```bash
docker network ls
```

Inspect the project network:

```bash
docker network inspect srcs_inception
```

Docker provides internal DNS. Services connect using names such as:

```text
mariadb:3306
wordpress:9000
redis:6379
```

Fixed container IP addresses, host networking, and legacy Docker links are not used.

## Volumes

Display the volumes:

```bash
docker volume ls
```

Inspect the MariaDB volume:

```bash
docker volume inspect srcs_mariadb_data
```

Inspect the WordPress volume:

```bash
docker volume inspect srcs_wordpress_data
```

The volume configuration points to:

```text
/home/clumertz/data/mariadb
/home/clumertz/data/wordpress
```

The exact `srcs_` prefix can change if a different Compose project name is used.

## Data persistence

MariaDB stores its data inside the container at:

```text
/var/lib/mysql
```

This is connected to:

```text
/home/clumertz/data/mariadb
```

WordPress stores its files inside the container at:

```text
/var/www/html
```

This is connected to:

```text
/home/clumertz/data/wordpress
```

Containers can be removed and recreated without deleting the website or database.

Test persistence by creating a WordPress post, running:

```bash
make down
make
```

Then verify that the post still exists.

## Mandatory service ports

- NGINX: `443`
- WordPress PHP-FPM: `9000`, internal only
- MariaDB: `3306`, internal only

## Bonus service ports

- Redis: `6379`, internal only
- FTP control connection: `21`
- FTP passive connections: `21000-21010`
- Static website: `8080`
- Adminer: `8081`
- cAdvisor: `8090`

## Access addresses

```text
WordPress:       https://clumertz.42.fr
WordPress admin: https://clumertz.42.fr/wp-admin/
Static website:  http://127.0.0.1:8080
Adminer:         http://127.0.0.1:8081
cAdvisor:        http://127.0.0.1:8090
FTP:             ftp://127.0.0.1
```

## Clean rebuild tests

Test only the mandatory part:

```bash
make fclean
make
make status
```

Test mandatory and bonus services:

```bash
make fclean
make bonus
make status
```
# Developer Documentation

## Prerequisites

The project must run inside a virtual machine with Docker.

The following programs are required:

- Docker Engine
- Docker Compose
- GNU Make
- Git

Check that they are installed:

```bash
docker --version
docker compose version
make --version
git --version
```

The current user must be allowed to run Docker commands. If `docker` is not listed, add the user to the Docker group:

```bash
sudo usermod -aG docker "$USER"
```

Log out and log back in after running this command.

## Project configuration

Clone the repository and enter its directory:

```bash
git clone <repository-url> inception
cd inception
```

## Host data directories

Create the directories used for persistent data:

```bash
mkdir -p /home/clumertz/data/mariadb
mkdir -p /home/clumertz/data/wordpress
```

These paths must match `DATA_PATH` in `srcs/.env`.

## Domain configuration

The project domain must resolve to the machine running Docker.

Add:

```text
127.0.0.1 clumertz.42.fr
```

## Build and launch with the Makefile

From the project root, run:

```bash
cd ~/inception
make
```

Check the service status:

```bash
make status
```

Stop and remove the containers:

```bash
make down
```

Start them again:

```bash
make
```

Remove the Docker resources created by the project:

```bash
make fclean
```

The persistent files under `/home/clumertz/data` may remain after `make fclean`.

## Build and launch with Docker Compose

Docker Compose commands must be executed from the `srcs` directory:

```bash
cd ~/inception/srcs
```

Validate the Compose configuration:

```bash
docker compose config --quiet
```

Build the images:

```bash
docker compose build
```

Start the services in the background:

```bash
docker compose up -d
```

Build changed images and start the services:

```bash
docker compose up -d --build
```

Stop and remove the containers and project network:

```bash
docker compose down
```

## Manage containers

Display the project containers:

```bash
docker compose ps
```

Display logs from every service:

```bash
docker compose logs
```

Restart all services:

```bash
docker compose restart
```


## Manage volumes

Display Docker volumes:

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


## Data storage and persistence

MariaDB data is stored on the host in:

```text
/home/clumertz/data/mariadb
```

It is mounted inside the MariaDB container at:

```text
/var/lib/mysql
```

WordPress data is stored on the host in:

```text
/home/clumertz/data/wordpress
```

It is mounted inside the WordPress container at:

```text
/var/www/html
```

The data is stored outside the containers. Removing and recreating a container does not remove the website or database.

To test persistence:

1. Create or modify content in WordPress.
2. Stop the project:

```bash
cd ~/inception
make down
```

3. Start the project again:

```bash
make
```

4. Open `https://clumertz.42.fr` and confirm that the content still exists.


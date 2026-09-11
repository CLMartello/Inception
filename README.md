*This project has been created as part of the 42 curriculum by clumertz.*

# Inception

## Description

Inception is a system administration project that builds a small containerized infrastructure inside a virtual machine using Docker Compose.

The mandatory infrastructure contains:

- NGINX as the only HTTPS entry point, using TLS 1.2 or TLS 1.3.
- WordPress running with PHP-FPM.
- MariaDB as the WordPress database.
- Two persistent volumes for WordPress and MariaDB data.
- A Docker bridge network connecting the services.

Each service runs in a dedicated container and is built from its own Debian-based Dockerfile.

The bonus infrastructure adds:

- Redis caching for WordPress.
- An FTP server connected to the WordPress volume.
- A static website.
- Adminer for database administration.
- cAdvisor for container resource monitoring.

## Architecture

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

The mandatory services communicate using their Docker Compose service names through the private `inception` network.

## Design choices

### Virtual machines and Docker

A virtual machine includes a complete operating system and its own kernel. It provides strong isolation but uses more resources.

Docker containers share the host kernel. They are smaller, start faster, and isolate individual services.

This project uses a virtual machine to host the project and Docker containers to separate its services.

### Secrets and environment variables

Environment variables are used for non-confidential configuration, such as the domain name, database name, and usernames.

Passwords are stored in local secret files and mounted inside the the containers under `/run/secrets`. Secret files and the real `.env` file must not be committed to Git.

The repository provides `srcs/.env.example` as a safe configuration template.

### Docker network and host network

The project uses a Docker bridge network. Docker provides internal DNS, allowing services to connect using names such as:

```text
wordpress
mariadb
redis
```

Host networking is not used because it would reduce isolation and expose container services directly through the host network.

### Docker volumes and bind mounts

Docker named volumes are managed by Docker and exist independently of containers.

This project uses named volumes configured with the local driver to store their data in the subject-required host directories:

```text
/home/clumertz/data/mariadb
/home/clumertz/data/wordpress
```

This preserves the database and website files when containers are removed or rebuilt.

## Instructions

### Requirements

The project must run inside a Linux virtual machine with:

- Docker Engine
- Docker Compose
- GNU Make

### Configuration

Copy the example environment file:

```bash
cp srcs/.env.example srcs/.env
```

Edit it with the correct login, domain, email addresses, and data path:

```bash
nano srcs/.env
```

Create the required password files using:

```bash
make secrets
```

Insert one password into each file before starting the project.

Add the project domain to `/etc/hosts`:

```text
127.0.0.1 clumertz.42.fr
```

### Mandatory part

Build and start the mandatory infrastructure:

```bash
make
```

Open:

```text
https://clumertz.42.fr
```

### Bonus part

Build and start the mandatory and bonus services:

```bash
make bonus
```

Bonus interfaces:

```text
Static website: http://127.0.0.1:8080
Adminer:        http://127.0.0.1:8081
cAdvisor:       http://127.0.0.1:8090
```

### Management

```bash
make status
make logs
make stop
make start
make restart
make down
make clean
make fclean
make re
```

See `USER_DOC.md` for usage instructions and `DEV_DOC.md` for setup, development, and maintenance information.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/docs/)
- [WordPress documentation](https://wordpress.org/documentation/)
- [WP-CLI documentation](https://make.wordpress.org/cli/handbook/)
- [Redis documentation](https://redis.io/docs/)
- [cAdvisor documentation](https://github.com/google/cadvisor)

## Use of AI

AI was used as a learning and review tool to:

- Explain Docker, networking, volumes, secrets, TLS, and service configuration.
- Divide the project into manageable implementation steps.
- Help diagnose errors using container logs.
- Draft documentation for later review.

All suggested commands and configurations were reviewed and tested inside the virtual machine. The project author remains responsible for understanding and explaining the complete implementation.
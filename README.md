*This project has been created as part of the 42 curriculum by clumertz.*

# Inception

## Description

Inception is a system administration project that creates a small web infrastructure using Docker Compose.

The project builds and runs three services:

- **NGINX** with TLS 1.2 and TLS 1.3 as the only public entry point.
- **WordPress with PHP-FPM** to run the website.
- **MariaDB** to store the WordPress database.

Each service runs in its own container and is built using its own Dockerfile based on Debian. Ready-made images for NGINX, WordPress, and MariaDB are not used.

The project includes:

- A Dockerfile and configuration files for each service.
- Entrypoint scripts used to initialize and start the services.
- A Docker Compose file that defines the services, network, volumes, secrets, health checks, and dependencies.
- A Makefile that builds and manages the infrastructure.
- Two named volumes for persistent WordPress and MariaDB data.
- A Docker bridge network for communication between the containers.

The request flow is:

```text
Client -> NGINX:443 -> WordPress/PHP-FPM:9000 -> MariaDB:3306
```

Only NGINX publishes a port to the host. WordPress and MariaDB are accessible only through the Docker network.

### Main design choices

Each container runs only its required service. The real service runs in the foreground as PID 1, allowing Docker to monitor it and stop it correctly.

The containers communicate using their Docker Compose service names instead of fixed IP addresses:

```text
nginx -> wordpress:9000
wordpress -> mariadb:3306
```

Passwords are stored in local secret files and mounted inside the containers under `/run/secrets`. Non-confidential configuration is stored in `.env`.

WordPress files and MariaDB data are stored in named volumes so that they remain available when containers are stopped or recreated.

### Virtual Machines vs Docker

A virtual machine includes a complete guest operating system and virtualized hardware. It provides strong isolation but requires more memory, disk space, and startup time.

A Docker container shares the host kernel and contains only the application and its required dependencies. Containers are lighter, start faster, and make it easier to reproduce the same service configuration.

This project runs Docker inside a virtual machine. The virtual machine provides the isolated host environment, while Docker separates the individual services.

### Secrets vs Environment Variables

Environment variables are suitable for non-confidential configuration such as:

- Domain names
- Database names
- Usernames
- Data paths

Secrets are more appropriate for confidential values such as passwords. Docker mounts each required secret as a file inside the container under `/run/secrets`.

This project stores non-secret configuration in `.env` and passwords in secret files. The real `.env` and secret files are excluded from Git.

### Docker Network vs Host Network

A Docker bridge network provides an isolated network where containers communicate using service names. Only explicitly published ports are accessible from the host.

Host networking makes a container share the host network directly, reducing isolation and potentially causing port conflicts.

This project uses a Docker bridge network. Host networking, `links`, and `--link` are not used.

### Docker Volumes vs Bind Mounts

Docker volumes provide persistent storage whose lifecycle is managed by Docker. They are identified by volume names and can be attached to containers without depending on the container filesystem.

A direct bind mount maps a host file or directory directly into a container and depends on a specific host path.

This project declares two named volumes through Docker Compose:

- One for the MariaDB database.
- One for the WordPress website files.

Their data is stored under:

```text
/home/clumertz/data/mariadb
/home/clumertz/data/wordpress
```

The volumes preserve the application data when containers are recreated.

## Instructions

Detailed installation, configuration, build, and container-management instructions are available in:

```text
DEV_DOC.md
```

Instructions for starting and stopping the project, accessing WordPress, managing credentials, and checking the services are available in:

```text
USER_DOC.md
```

To build and start the project:

```bash
make
```

The website is available at:

```text
https://clumertz.42.fr
```

The WordPress administration panel is available at:

```text
https://clumertz.42.fr/wp-admin
```

## Resources

The following official documentation was used as a reference:

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Docker networking documentation](https://docs.docker.com/engine/network/)
- [Docker storage and volumes documentation](https://docs.docker.com/engine/storage/volumes/)
- [Docker Compose secrets documentation](https://docs.docker.com/compose/how-tos/use-secrets/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress documentation](https://wordpress.org/documentation/)
- [WP-CLI documentation](https://make.wordpress.org/cli/handbook/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)
- [MariaDB documentation](https://mariadb.com/docs/)
- [Debian documentation](https://www.debian.org/doc/)

### Use of AI

AI was used as a learning and support tool during the project.

It was used to:

- Explain Docker, Docker Compose, containers, images, networks, volumes, secrets, and PID 1.
- Explain the roles of NGINX, WordPress, PHP-FPM, and MariaDB.
- Explain configuration files and entrypoint scripts.
- Help draft the project documentation.

The generated suggestions were reviewed, tested, and adapted before being included in the project. AI was not used as a replacement for understanding the configuration or the implementation.

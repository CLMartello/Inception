# User Documentation

## Services provided

This project runs three services with Docker Compose:

- **NGINX** receives HTTPS connections and provides access to the website.
- **WordPress with PHP-FPM** runs the website and administration panel.
- **MariaDB** stores the WordPress database.

Only NGINX is accessible directly from the host. WordPress and MariaDB communicate through the internal Docker network.

## Start the project

Open a terminal and go to the project directory:

```bash
cd ~/inception
```

Start the project:

```bash
make
```

The first start may take several minutes because Docker must build the images and initialize WordPress and MariaDB.

## Stop the project

Stop and remove the running containers:

```bash
make down
```

The WordPress files and MariaDB database remain stored in the persistent volumes.


## Access the website

Open the website in a browser:

```text
https://clumertz.42.fr
```

The project uses a self-signed TLS certificate. The browser may display a security warning. For this local project, select the advanced option and continue to the website.

## Access the administration panel

Open:

```text
https://clumertz.42.fr/wp-admin
```

## Check the services

From the project directory, run:

```bash
make status
```


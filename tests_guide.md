
# Inception Test Commands

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

Replace login = clumertz
Replace @example.com = @42.fr

The real `.env` file must not be committed to Git.

Run commands from the project root:

```bash
cd ~/inception
```

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

## Mandatory Part

### Build and start mandatory services

```bash
make
```

### Show running containers

```bash
make status
```

Expected mandatory containers:

- `mariadb`
- `wordpress`
- `nginx`

Only NGINX should publish port `443` to the host.

### Test HTTPS

```bash
curl -kI https://clumertz.42.fr
```

A successful response normally contains:

```text
HTTP/1.1 200 OK
```

### Check the TLS configuration

```bash
docker compose -f srcs/docker-compose.yml exec nginx nginx -T 2>/dev/null | grep ssl_protocols
```

Expected:

```text
ssl_protocols TLSv1.2 TLSv1.3;
```

### Check exposed ports

```bash
make status
```

Expected internal service ports:

- MariaDB: `3306`
- WordPress PHP-FPM: `9000`
- NGINX: host port `443`

### Check Docker images

```bash
docker image ls
```

### Check the Docker network

```bash
docker network ls
```

### Check the volumes

```bash
docker volume ls
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data
```

The output should contain:

```text
/home/clumertz/data/mariadb
/home/clumertz/data/wordpress
```

### Check WordPress files

```bash
ls -la /home/clumertz/data/wordpress
```

### Log in to MariaDB

```bash
docker compose -f srcs/docker-compose.yml exec mariadb mariadb -u root -p
```

Enter the password stored in:

```text
secrets/db_root_password.txt
```

Useful SQL commands:

```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT * FROM wp_comments;
EXIT;
```

### Log in as the WordPress database user

```bash
docker compose -f srcs/docker-compose.yml exec mariadb mariadb -u wpuser -p wordpress
```

Enter the password stored in:

```text
secrets/db_password.txt
```

Then test:

```sql
SELECT USER(), DATABASE();
SHOW TABLES;
SHOW GRANTS;
EXIT;
```


### Check PID 1 in each container

```bash
docker compose -f srcs/docker-compose.yml exec mariadb ps -p 1 -o pid,comm,args
docker compose -f srcs/docker-compose.yml exec wordpress ps -p 1 -o pid,comm,args
docker top nginx
```

The real service should be running as PID 1 or with daemon off.

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

Include a new comment.

Use:

```text
Username: value of WP_ADMIN_USER in srcs/.env
Password: content of secrets/wp_admin_password.txt
```

Accept the comment and modify one post.

A regular WordPress user is also created using `WP_USER` and `wp_user_password.txt`.

### Stop mandatory services

```bash
make stop
```

### Start mandatory services

```bash
make start
```

### Restart mandatory services

```bash
make restart
```

### Remove the project containers

```bash
make down
```

### Clean rebuild of the mandatory part

```bash
make fclean
make
```

Verify the new comment and the modify post are there.

---

# Bonus Part

## Start mandatory and bonus services

```bash
make bonus
```

### Show all running services

```bash
make status
```

Expected bonus services:

- `redis`
- `ftp`
- `website`
- `adminer`
- `cadvisor`

---

## Redis

### Test the Redis server

```bash
docker compose -f srcs/docker-compose.yml --profile bonus exec redis redis-cli ping
```

Expected:

```text
PONG
```

### Show Redis information

```bash
docker compose -f srcs/docker-compose.yml --profile bonus exec redis redis-cli info server
```

---

## FTP

### Check the FTP container and ports

```bash
docker compose -f srcs/docker-compose.yml --profile bonus ps ftp
```

Expected published ports:

- Control port: `21`
- Passive data ports: `21000-21010`

### Connect from the terminal

```bash
curl --user clumertz_ftp ftp://127.0.0.1/
```

Curl asks for the FTP password. Use the password stored in:

```text
secrets/ftp_password.txt
```

---

## Static Website

### Test the static website

```bash
curl -I http://127.0.0.1:8080
```

Expected:

```text
HTTP/1.1 200 OK
```

Open it in the browser:

```text
http://127.0.0.1:8080
```

### Check the static website container

```bash
docker compose -f srcs/docker-compose.yml --profile bonus ps website
```

### Check its NGINX configuration

```bash
docker compose -f srcs/docker-compose.yml --profile bonus exec website nginx -T
```

---

## Adminer

### Test the Adminer page

```bash
curl -I http://127.0.0.1:8081
```

Open it in the browser:

```text
http://127.0.0.1:8081
```

Login information:

```text
System: MySQL
Server: mariadb
Username: wpuser
Password: content of secrets/db_password.txt
Database: wordpress
```

After logging in, verify that the WordPress database and its tables are visible.

---

## cAdvisor

### Test the cAdvisor page

```bash
curl -I http://127.0.0.1:8090
```

Open it in the browser:

```text
http://127.0.0.1:8090
```

### Check the cAdvisor container

```bash
docker compose -f srcs/docker-compose.yml --profile bonus ps cadvisor
```

### Check cAdvisor metrics

```bash
curl -s http://127.0.0.1:8090/metrics | head
```

The output should contain Prometheus-style metrics.

### Check cAdvisor logs

```bash
docker compose -f srcs/docker-compose.yml --profile bonus logs --tail=50 cadvisor
```

---

## Final Bonus Rebuild

Remove the current project:

```bash
make fclean
```

Build and start mandatory plus bonus:

```bash
make bonus
```

Show all services:

```bash
docker compose -f srcs/docker-compose.yml --profile bonus ps
```

Test the browser addresses:

```text
https://clumertz.42.fr
http://127.0.0.1:8080
http://127.0.0.1:8081
http://127.0.0.1:8090
```

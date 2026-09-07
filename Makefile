
COMPOSE := docker compose -f srcs/docker-compose.yml
DATA_DIR := /home/clumertz/data
SECRET_DIR := secrets
SECRET_FILES := \
	$(SECRET_DIR)/db_root_password.txt \
	$(SECRET_DIR)/db_password.txt \
	$(SECRET_DIR)/wp_admin_password.txt \
	$(SECRET_DIR)/wp_user_password.txt

all: up

secrets:
	mkdir -p $(SECRET_DIR)
	test -f $(SECRET_DIR)/db_root_password.txt || install -m 600 /dev/null $(SECRET_DIR)/db_root_password.txt
	test -f $(SECRET_DIR)/db_password.txt || install -m 600 /dev/null $(SECRET_DIR)/db_password.txt
	test -f $(SECRET_DIR)/wp_admin_password.txt || install -m 600 /dev/null $(SECRET_DIR)/wp_admin_password.txt
	test -f $(SECRET_DIR)/wp_user_password.txt || install -m 600 /dev/null $(SECRET_DIR)/wp_user_password.txt
	chmod 600 $(SECRET_FILES)
	@echo "Secret files are ready under $(SECRET_DIR)/"

check-secrets: secrets
	@test -s $(SECRET_DIR)/db_root_password.txt || { echo "Error: db_root_password.txt is empty"; exit 1; }
	@test -s $(SECRET_DIR)/db_password.txt || { echo "Error: db_password.txt is empty"; exit 1; }
	@test -s $(SECRET_DIR)/wp_admin_password.txt || { echo "Error: wp_admin_password.txt is empty"; exit 1; }
	@test -s $(SECRET_DIR)/wp_user_password.txt || { echo "Error: wp_user_password.txt is empty"; exit 1; }

prepare: check-secrets
	mkdir -p $(DATA_DIR)/mariadb
	mkdir -p $(DATA_DIR)/wordpress
	
up: prepare
	$(COMPOSE) up -d --build
	
down:
	$(COMPOSE) down
	
start:
	$(COMPOSE) start
	
stop:
	$(COMPOSE) stop
	
restart:
	$(COMPOSE) restart
	
status:
	$(COMPOSE) ps
	
logs:
	$(COMPOSE) logs -f
	
clean:
	$(COMPOSE) down --remove-orphans
	
fclean:
	$(COMPOSE) down --rmi all --volumes --remove-orphans
	
re: fclean up

.PHONY: all secrets check-secrets prepare up down start stop restart status logs clean fclean re

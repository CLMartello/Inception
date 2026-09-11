
COMPOSE := docker compose -f srcs/docker-compose.yml
BONUS_COMPOSE := $(COMPOSE) --profile bonus

DATA_DIR := /home/clumertz/data
SECRET_DIR := secrets

SECRET_FILES := \
	$(SECRET_DIR)/db_root_password.txt \
	$(SECRET_DIR)/db_password.txt \
	$(SECRET_DIR)/wp_admin_password.txt \
	$(SECRET_DIR)/wp_user_password.txt \
	$(SECRET_DIR)/ftp_password.txt

all: up

secrets:
	mkdir -p $(SECRET_DIR)
	test -f $(SECRET_DIR)/db_root_password.txt || install -m 600 /dev/null $(SECRET_DIR)/db_root_password.txt
	test -f $(SECRET_DIR)/db_password.txt || install -m 600 /dev/null $(SECRET_DIR)/db_password.txt
	test -f $(SECRET_DIR)/wp_admin_password.txt || install -m 600 /dev/null $(SECRET_DIR)/wp_admin_password.txt
	test -f $(SECRET_DIR)/wp_user_password.txt || install -m 600 /dev/null $(SECRET_DIR)/wp_user_password.txt
	test -f $(SECRET_DIR)/ftp_password.txt || install -m 600 /dev/null $(SECRET_DIR)/ftp_password.txt
	chmod 600 $(SECRET_FILES)
	@echo "Secret files are ready under $(SECRET_DIR)/"

check-secrets: secrets
	@test -s $(SECRET_DIR)/db_root_password.txt || { echo "Error: db_root_password.txt is empty"; exit 1; }
	@test -s $(SECRET_DIR)/db_password.txt || { echo "Error: db_password.txt is empty"; exit 1; }
	@test -s $(SECRET_DIR)/wp_admin_password.txt || { echo "Error: wp_admin_password.txt is empty"; exit 1; }
	@test -s $(SECRET_DIR)/wp_user_password.txt || { echo "Error: wp_user_password.txt is empty"; exit 1; }

check-bonus-secrets: secrets
	@test -s $(SECRET_DIR)/ftp_password.txt || { echo "Error: ftp_password.txt is empty"; exit 1; }

prepare: check-secrets
	mkdir -p $(DATA_DIR)/mariadb
	mkdir -p $(DATA_DIR)/wordpress
	
bonus-prepare: prepare check-bonus-secrets
	
up: prepare
	$(COMPOSE) up -d --build
	
bonus: bonus-prepare
	$(BONUS_COMPOSE) up -d --build
	
down:
	$(BONUS_COMPOSE) down
	
start:
	$(COMPOSE) start

bonus-start:
	$(BONUS_COMPOSE) start
	
stop:
	$(BONUS_COMPOSE) stop
	
restart:
	$(COMPOSE) restart

bonus-restart:
	$(BONUS_COMPOSE) restart
	
status:
	$(COMPOSE) ps
	
logs:
	$(COMPOSE) logs -f
	
clean:
	$(BONUS_COMPOSE) down --remove-orphans
	
fclean:
	$(BONUS_COMPOSE) down --rmi all --volumes --remove-orphans
	
re: fclean up

.PHONY: all secrets check-secrets prepare \
	check-bonus-secrets bonus-prepare \
	up down start stop restart status logs clean fclean re \
	bonus bonus-start bonus-restart

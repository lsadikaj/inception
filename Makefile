
COMPOSE_FILE = src/docker-compose.yml

all:
	docker compose -f $(COMPOSE_FILE) up -d --build

down:
	docker compose -f $(COMPOSE_FILE) down
	
clean: down
	docker compose -f $(COMPOSE_FILE) down --rmi all --volumes --remove-orphans

re: clean all

.PHONY: all down clean re
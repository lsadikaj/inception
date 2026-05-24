
# Le chemain vers le docker-compose.yml
COMPOSE_FILE = src/docker-compose.yml

# La règle par défaut, lance et build tous les containeurs
all:
	docker compose -f $(COMPOSE_FILE) up -d --build

# Arrète les containeurs sans les supprimer
down:
	docker compose -f $(COMPOSE_FILE) down
	
# Supprime containeurs, images buildées et volume
clean: down
	docker compose -f $(COMPOSE_FILE) down --rmi all --volumes --remove-orphans

# Repartir de zéro
re: clean all

# Ces règles ne correspondent pas à des fichiers
.PHONY: all down clean re
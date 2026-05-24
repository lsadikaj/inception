# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: lsadikaj <lsadikaj@student.42lausanne.ch>  +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/05/23 16:36:57 by lsadikaj          #+#    #+#              #
#    Updated: 2026/05/23 16:43:31 by lsadikaj         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

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
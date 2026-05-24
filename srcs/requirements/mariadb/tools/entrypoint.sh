
#!/bin/bash
set -e

# On lit les mots de passe depuis les fichiers secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# On vérifie si c'est le premier démarrage
if [ ! -d "/var/lib/mysql/mysql" ]; then

	# Initialise le système de fichiers de MariaDB
	mysql_install_db --user=mysql --datadir=/var/lib/mysql

	# On démarre MariaDB temporairement en arrière-plan
	mysql --user=mysql --bootstrap &
	TEMP_PID=$!

	# On attend que MariaDB soit prêt à recevoir des connexions
	sleep 3

	# On envoie les commandes SQL d'initialisation à MariaDB
	mysql --user=mysql <<-EOF
		CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
		FLUSH PRIVILEGES;
		EOF
	
	# On arrête proprement le MariaDB temporaire
	kill $TEMP_PID
	wait $TEMP_PID
	
fi

# On remplace le processus shell (PID 1) par MariaDB
exec mysql --user=mysql


#!/bin/bash
set -e

# Lecture des secrets depuis les fichiers montés par Docker
DB_PASSWORD=$(cat /run/secrets/db_password)
CREDENTIALS=$(cat /run/secrets/credentials)

# On extrait le nom d'utilisateur et le mot de passe admin WordPress
# depuis le fichier credentials qui contient "lsadikaj_wp:wppass123"
# La commande "cut" découpe la chaîne selon le séparateur ":"
# -d':' définit le séparateur, -f1 prend le premier champ, -f2 le deuxième
WP_ADMIN_USER=$(echo "$CREDENTIALS" | cut -d':' -f1)
WP_ADMIN_PASSWORD=$(echo "$CREDENTIALS" | cut -d':' -f2)

# On attend que MariaDB soit prêt à accepter des connexions
# Cette boucle tente de se connecter toutes les secondes
echo "Waiting for mariadb to be ready..."
until mysqladmin ping -h mariadb -u"$MYSQL_USER" -p"$DB_PASSWORD" silend; do
	echo "Mariadb not ready yet, retrying in 1 second..."
	sleep 1
done
echo "Mariadb is ready."

# On vérifie si c'est le premier démarrage
# wp-settings.php est un fichier central de WordPress
# qui n'existe que si WordPress a déjà été téléchargé
if [ ! -f "/var/www/html/wp-setting.php" ]; then
	echo "Installing wordpress..."
	# On se place dans le dossier où WordPress sera installé
	cd /var/www/html
	# Étape 1 : Télécharger les fichiers WordPress
    # --allow-root permet à WP-CLI de tourner en tant que root
    # --locale=fr_FR installe WordPress en français
	wp core download --allow-root --locale=fr_FR
	# Étape 2 : Créer le fichier wp-config.php
    # C'est le fichier de configuration principal de WordPress
    # Il contient les informations de connexion à la base de données
    # "mariadb" est le nom du conteneur, Docker le résout via DNS
	wp config create \
		--allow-root \
		--dbname="$MYSQL_DATABASE" \
		--dbuser="$MYSQL_USER" \
		--dbpass="$DB_PASSWORD" \
		--dbhost="mariadb" \
		--dbcharset="utf8mb4"
	# Étape 3 : Installer WordPress, c'est ici qu'on crée le site
    # C'est l'équivalent de remplir le formulaire d'installation
    # dans le navigateur
	wp core install \
		--allow-root \
		--url="https://$DOMAIN_NAME" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--skip_email
	# Étape 4 : Créer un deuxième utilisateur non-administrateur
    # Le subject exige deux utilisateurs dans la base de données
    # un admin et un utilisateur normal
	wp user create \
		--allow-root \
		"$WP_USER" "$WP_USER_MAIL" \
		--role=author \
		--user-pass="$WP_USER_PASSWORD"
	
	echo "Wordpress installed successfully."

fi

echo "Starting PHP-FPM..."
exec php-fmp8.2 -f --nodaemonize
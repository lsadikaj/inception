#!/bin/bash
set -e

# On crée le dossier qui contiendra le certificat et la clé privée
# -p évite une erreur si le dossier existe déjà
mkdir -p /etc/nginx/ssl

# On génère le certificat auto-signé avec OpenSSL
# Cette commande fait deux choses en une :
# elle génère la clé privée ET le certificat en même temps
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/private.key \
		-out /etc/nginx/ssl/certificate.crt \
		-subj "/C=CH/ST=Vaud/L=Lausanne/O=42/CN=lsadikaj.42.fr"

echo "Starting NGINX..."

# "daemon off" force NGINX à rester au premier plan
# Sans cette option NGINX se lancerait en daemon,
# libérerait le terminal, et le conteneur s'arrêterait immédiatement
exec nginx -g "daemon off;"

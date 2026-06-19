
#!/bin/bash
set -e

MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

if [ ! -d "/var/lib/mysql/mysql" ]; then

	mysql_install_db --user=mysql --datadir=/var/lib/mysql

	mysqld --user=mysql --bootstrap &
	TEMP_PID=$!

	sleep 3

	mysql --user=mysql <<-EOF
		CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
		FLUSH PRIVILEGES;
		EOF
	
	kill $TEMP_PID
	wait $TEMP_PID
	
fi

exec mysql --user=mysql

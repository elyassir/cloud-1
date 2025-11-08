apt-get update &&
	apt-get upgrade -y &&
	apt-get install mariadb-server -y &&
	apt-get install mariadb-client -y &&
	sed -i 's/bind-address.*/ bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf &&
	service mariadb start &&
	mariadb --password="${DB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;
  CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
  GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
  ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password;
  SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${DB_ROOT_PASSWORD}');
  FLUSH PRIVILEGES;"

apt-get update &&
	apt-get upgrade -y &&
	apt-get install php-fpm -y &&
	apt-get install php-mysql -y &&
	apt-get install php-curl -y &&
	apt-get install php-redis -y &&
	# apt-get install sendmail -y &&
	mkdir -p /run/php/ &&
	echo "listen = 0.0.0.0:9000" >> /etc/php/7.4/fpm/php-fpm.conf &&
	# mv /wp-cli.phar /bin/wp &&
	chmod +x /bin/wp &&
	wp core download --allow-root &&
	wp config create --dbname="${DB_NAME}" --dbuser="${DB_USER}" --dbpass="${DB_PASSWORD}" --dbhost="${DB_HOST}" --skip-check --force --allow-root

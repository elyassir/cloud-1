apt-get update &&
	apt-get upgrade -y &&
	apt-get install openssl -y &&
	mkdir -p "${CRS_PATH}" &&
	openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 \
		-keyout "${CRS_PATH}/nginx.key" \
		-out "${CRS_PATH}/nginx.csr" \
		-subj "/C=${CRS_COUNTRYCODE}/ST=${CRS_STATE}/L=${CRS_LOCATION}/O=${CRS_ORGANIZATION}/OU=${CRS_SECTION}/CN=${CRS_COMMONNAME}/emailAddress=${CRS_EMAIL}"

CONF_PATH="/default"

echo "server {" >"${CONF_PATH}"
echo "  listen 443 ssl;" >>"${CONF_PATH}"
echo "  listen [::]:443 ssl;" >>"${CONF_PATH}"
echo "" >>"${CONF_PATH}"
echo "  root /var/www/elyassir/;" >>"${CONF_PATH}"
echo "" >>"${CONF_PATH}"
echo "  server_name ${CRS_COMMONNAME} www.${CRS_COMMONNAME};" >>"${CONF_PATH}"
echo "" >>"${CONF_PATH}"
echo "  ssl_certificate ${CRS_PATH}/nginx.csr;" >>"${CONF_PATH}"
echo "  ssl_certificate_key ${CRS_PATH}/nginx.key;" >>"${CONF_PATH}"
echo "  ssl_protocols TLSv1.3;" >>"${CONF_PATH}"
echo "" >>"${CONF_PATH}"
echo "  error_log /dev/stderr;" >>"${CONF_PATH}"
echo "  # access_log /dev/stdout;" >>"${CONF_PATH}"
echo "" >>"${CONF_PATH}"
echo "  autoindex on;" >>"${CONF_PATH}"
echo "" >>"${CONF_PATH}"
echo "  index index.php;" >>"${CONF_PATH}"
echo "" >>"${CONF_PATH}"
echo '  location ~ \.php$ {' >>"${CONF_PATH}"
echo "    include snippets/fastcgi-php.conf;" >>"${CONF_PATH}"
echo "    fastcgi_pass wordpress:9000;" >>"${CONF_PATH}"
echo "  }" >>"${CONF_PATH}"
echo "}" >>"${CONF_PATH}"
echo "" >>"${CONF_PATH}"
echo "server {" >>"${CONF_PATH}"
echo "    listen 80;" >>"${CONF_PATH}"
echo "    listen [::]:80;" >>"${CONF_PATH}"
echo "    server_name ${CRS_COMMONNAME} www.${CRS_COMMONNAME};" >>"${CONF_PATH}"
echo "" >>"${CONF_PATH}"
echo '    return 301 https://\$host\$request_uri;' >>"${CONF_PATH}"
echo "}" >>"${CONF_PATH}"

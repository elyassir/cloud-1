if ! wp core is-installed --allow-root; then

  wp core install --url="$WP_URL" --title="$WP_TITLE" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASS" --admin_email="$WP_ADMIN_EMAIL" --skip-email --allow-root

  wp user create "$WP_USER" "$WP_EMAIL" --role=author --user_pass="$WP_PASS" --display_name="$WP_NAME" --allow-root

  wp theme install oceanedge --activate --allow-root

  wp plugin update --all --allow-root

  chown www-data:www-data -R .

  chmod -R g+rw .

fi

exec php-fpm7.4 -F

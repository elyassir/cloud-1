FROM debian:11 AS BASE

ARG DB_NAME DB_USER DB_PASSWORD DB_HOST WP_URL REDIS_PASS

WORKDIR /var/www/elyassir

ADD --chmod=777 https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /bin/wp

COPY --chmod=777 ./tools/* /

RUN /wordpress_build.sh

ENTRYPOINT [ "bash", "/wordpress_run.sh" ]

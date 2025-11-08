FROM debian:11 AS BASE

ARG DB_NAME DB_USER DB_PASSWORD DB_ROOT_PASSWORD

COPY --chmod=777 ./tools/* /

RUN /mariadb_build.sh

ENTRYPOINT [ "mariadbd" ]

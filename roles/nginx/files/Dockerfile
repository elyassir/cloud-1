FROM debian:11 AS build

ARG CRS_COUNTRYCODE CRS_STATE CRS_LOCATION CRS_ORGANIZATION CRS_SECTION CRS_COMMONNAME CRS_EMAIL CRS_PATH 

COPY  --chmod=777 ./tools/config_build.sh /

RUN /config_build.sh

FROM debian:11 AS BASE

EXPOSE 443

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install nginx -y

COPY --from=build ${CRS_PATH} ${CRS_PATH}

COPY --from=build /default /etc/nginx/sites-available/default

ENTRYPOINT [ "nginx", "-g", "daemon off;" ]

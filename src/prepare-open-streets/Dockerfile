FROM mdillon/postgis:9.4

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY functions.sql /usr/src/app/functions.sql
ENV SQL_FILE=/usr/src/app/functions.sql

COPY prepare.sh /usr/src/app/
CMD ["./prepare.sh"]

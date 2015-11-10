FROM mdillon/postgis:9.4

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app

ENV SQL_FILE=/usr/src/app/update.sql
CMD ["./update-scaleranks.sh"]

FROM mdillon/postgis:9.4

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app
CMD ["./update-scaleranks.sh"]

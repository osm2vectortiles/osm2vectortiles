FROM mdillon/postgis:9.4

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      wget unzip \
      --no-install-recommends

RUN mkdir -p /usr/src/app
COPY import.sh /usr/src/app/
WORKDIR /usr/src/app

CMD ["./import.sh"]
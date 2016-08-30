FROM ubuntu:16.04

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      apt-transport-https \
      osm2pgsql \
      curl \
      wget \
      unzip \
      npm \
      git \
      make \
      postgresql-contrib \
&& echo "deb https://deb.nodesource.com/node_5.x xenial main" >> /etc/apt/sources.list.d/nodejs.list \
&& echo "deb-src https://deb.nodesource.com/node_5.x xenial main" >> /etc/apt/sources.list.d/nodejs.list \
&& apt-get -qq update \
&& DEBIAN_FRONTEND=noninteractive apt-get -y --allow-unauthenticated install \
    nodejs \
&& rm /etc/apt/sources.list.d/nodejs.list \
&& apt-get clean

RUN git clone https://github.com/stirringhalo/openstreetmap-carto-vector-tiles.git

VOLUME /data/import /data/cache
ENV IMPORT_DATA_DIR=/data/import

WORKDIR /usr/src/app
COPY . /usr/src/app/

CMD ["./import-osm2pgsql.sh"]

FROM node:4.3.1
MAINTAINER Lukas Martinelli <me@lukasmartinelli.ch>

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN npm install -g \
      tilelive@5.12.1 \
      mapnik@3.4.9 \
      mbtiles@0.8.2 \
      tilelive-tmsource@0.4.2 \
      tilelive-vector@3.5.1 \
      tilelive-bridge@2.2.1 \
      tilelive-mapnik@0.6.17

RUN apt-get update && apt-get install -y --no-install-recommends \
        sqlite3 \
        bc \
    && rm -rf /var/lib/apt/lists/

VOLUME /data/export
ENV WORLD_MBTILES=/data/export/world.mbtiles

COPY . /usr/src/app/
CMD ["./create-extracts.sh"]

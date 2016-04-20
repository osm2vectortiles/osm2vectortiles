FROM node:5
MAINTAINER Lukas Martinelli <me@lukasmartinelli.ch>

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN npm install -g \
      tilelive@5.12.x \
      mapnik@3.5.x \
      mbtiles@0.8.x \
      tilelive-tmsource@0.4.x \
      tilelive-vector@3.9.x \
      tilelive-bridge@2.3.x \
      tilelive-mapnik@0.6.x

RUN npm -g outdated | grep -v npm

RUN apt-get update && apt-get install -y --no-install-recommends \
        sqlite3 \
        bc \
        s3cmd \
    && rm -rf /var/lib/apt/lists/

VOLUME /data/export
ENV WORLD_MBTILES=/data/export/world.mbtiles \
    PATCH_MBTILES=/data/export/world_z0-z5.mbtiles \
    S3_CONFIG_FILE=/usr/src/app/.s3cfg

COPY . /usr/src/app/
CMD ["./create-extracts.sh"]

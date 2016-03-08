FROM node:0.10
MAINTAINER Lukas Martinelli <me@lukasmartinelli.ch>

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN npm install -g \
          tl@0.8.x \
          mapnik@3.5.x \
          mbtiles@0.8.x \
          tilelive@5.12.x \
          tilelive-tmsource@0.4.x \
          tilelive-vector@3.9.x \
          tilelive-bridge@2.3.x \
          tilelive-mapnik@0.6.x

RUN npm -g outdated | grep -v npm

RUN apt-get update && apt-get install -y --no-install-recommends \
        python \
        python-pip \
    && rm -rf /var/lib/apt/lists/

VOLUME /data/tm2source /data/export
ENV SOURCE_PROJECT_DIR=/data/tm2source EXPORT_DIR=/data/export TILELIVE_BIN=tl

COPY requirements.txt /usr/src/app/requirements.txt
RUN pip install -r requirements.txt
COPY . /usr/src/app/

CMD ["/usr/src/app/export-local.sh"]

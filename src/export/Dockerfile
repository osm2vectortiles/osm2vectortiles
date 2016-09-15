FROM node:5
MAINTAINER Lukas Martinelli <me@lukasmartinelli.ch>

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN npm install -g \
          tl@0.8.1 \
          mapnik@3.5.13 \
          mbtiles@0.8.2 \
          tilelive@5.12.2 \
          tilelive-tmsource@0.5.0 \
          tilelive-vector@3.9.3 \
          tilelive-bridge@2.3.1 \
          tilelive-mapnik@0.6.18

RUN npm -g outdated | grep -v npm

RUN apt-get update && apt-get install -y --no-install-recommends \
        python \
        python-pip \
        python-dev \
    && rm -rf /var/lib/apt/lists/

VOLUME /data/tm2source /data/export
ENV SOURCE_PROJECT_DIR=/data/tm2source EXPORT_DIR=/data/export TILELIVE_BIN=tl

COPY requirements.txt /usr/src/app/requirements.txt
RUN pip install -r requirements.txt
COPY . /usr/src/app/

CMD ["/usr/src/app/export-local.sh"]

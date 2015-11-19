FROM node:0.10
MAINTAINER Lukas Martinelli <me@lukasmartinelli.ch>

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN npm install -g tl@0.4.0 \
          mapnik@3.4.9 \
          mbtiles@0.8.2 \
          tilelive-tmsource@0.4.2 \
          tilelive-vector@3.5.1 \
          tilelive-bridge@2.2.1 \
          tilelive-mapnik@0.6.17

RUN apt-get update && apt-get install -y --no-install-recommends \
        python \
        python-pip \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /usr/src/app/requirements.txt
RUN pip install -r requirements.txt

# custom tm2source project
VOLUME /data/tm2source
ENV SOURCE_PROJECT_DIR=/data/tm2source

# destination for exported vector tiles
VOLUME /data/export
ENV EXPORT_DIR=/data/export

COPY export.py /usr/src/app/
COPY export.sh /usr/src/app/
CMD ["/usr/src/app/export.sh"]

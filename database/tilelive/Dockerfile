FROM node:0.10
MAINTAINER Lukas Martinelli <me@lukasmartinelli.ch>

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN npm install -g tl \
	   mbtiles \
           tilelive-tmsource \
           tilelive-vector \
	   tilelive-bridge \
	   tilelive-mapnik

# custom tm2source project
VOLUME /data/tm2source
ENV SOURCE_PROJECT_DIR=/data/tm2source

# destination for exported vector tiles
VOLUME /data/export
ENV EXPORT_DIR=/data/export

COPY export.sh /usr/src/app/export.sh

CMD ["/usr/src/app/export.sh"]

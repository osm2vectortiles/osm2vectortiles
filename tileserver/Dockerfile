FROM node:0.10
MAINTAINER Lukas Martinelli <me@lukasmartinelli.ch>

RUN mkdir -p /tmp/mapbox-studio-default-fonts && \
    mkdir -p /fonts && \
    git clone https://github.com/mapbox/mapbox-studio-default-fonts.git /tmp/mapbox-studio-default-fonts && \
    cp /tmp/mapbox-studio-default-fonts/**/*.otf /fonts && \
    cp /tmp/mapbox-studio-default-fonts/**/*.ttf /fonts && \
    rm -rf /tmp/mapbox-studio-default-fonts

RUN npm install -g tessera
RUN npm install -g mbtiles \
		   tilelive-tmstyle \
	 	   tilelive-http

COPY config.json /usr/src/app/config.json
VOLUME /data

ENV MAPNIK_FONT_PATH=/fonts
ENV PORT=80

EXPOSE 80
CMD ["tessera", "-c", "/usr/src/app/config.json"]

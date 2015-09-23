FROM node:0.10
MAINTAINER Lukas Martinelli <me@lukasmartinelli.ch>

# make sure the mapbox fonts are available on the system
RUN mkdir -p /tmp/mapbox-studio-default-fonts && \
    mkdir -p /fonts && \
    git clone https://github.com/mapbox/mapbox-studio-default-fonts.git /tmp/mapbox-studio-default-fonts && \
    cp /tmp/mapbox-studio-default-fonts/**/*.otf /fonts && \
    cp /tmp/mapbox-studio-default-fonts/**/*.ttf /fonts && \
    rm -rf /tmp/mapbox-studio-default-fonts
ENV MAPNIK_FONT_PATH=/fonts

# only install minimal amount of tessera packages
# be careful as some tessera packages collide with itself
RUN npm install -g tessera
RUN npm install -g mbtiles \
           tilelive-tmstyle \
           tilelive-http

RUN mkdir -p /usr/src/app
COPY run.sh /usr/src/app/

# mountpoint of custom mbtiles files and tm2 projects
VOLUME /data
ENV SOURCE_DATA_DIR=/data

# destination of modified tm2 projects
VOLUME /project
ENV DEST_DATA_DIR=/project

EXPOSE 80
ENV PORT=80

CMD ["/usr/src/app/run.sh"]

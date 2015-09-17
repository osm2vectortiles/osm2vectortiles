FROM node:0.12.7
MAINTAINER Lukas Martinelli <me@lukasmartinelli.ch>

RUN npm install -g tessera
RUN npm install -g mbtiles tilelive-tmstyle tilelive-tmsource

VOLUME /data
WORKDIR /data
EXPOSE 8080

FROM node:5

RUN npm install -g \
          mapnik@3.5.x \
          tilelive@5.12.x \
          tilelive-tmsource@0.4.x \
          tilelive-vector@3.9.x \
          tilelive-bridge@2.3.x \
          tilelive-mapnik@0.6.x \
          tessera@0.9.x

COPY bright-v9.json index.html /usr/local/lib/node_modules/tessera/public/
VOLUME /data/tm2source
EXPOSE 3030
CMD ["tessera", "tmsource:///data/tm2source", "--port", "3030"]

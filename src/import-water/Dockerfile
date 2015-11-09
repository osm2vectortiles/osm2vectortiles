FROM mdillon/postgis:9.4

RUN apt-get update && apt-get install -y --no-install-recommends \
      wget \
      unzip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /data/import && wget --quiet http://data.openstreetmapdata.com/water-polygons-split-3857.zip && unzip -oj water-polygons-split-3857.zip -d /data/import && rm water-polygons-split-3857.zip

RUN wget --quiet http://data.openstreetmapdata.com/land-polygons-complete-3857.zip && unzip -oj land-polygons-complete-3857.zip -d /data/import && rm land-polygons-complete-3857.zip

ENV IMPORT_DATA_DIR=/data/import

RUN mkdir -p /usr/src/app
COPY import.sh /usr/src/app/
WORKDIR /usr/src/app

CMD ["./import.sh"]

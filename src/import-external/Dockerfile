FROM mdillon/postgis:9.4

RUN apt-get update && apt-get install -y --no-install-recommends \
      wget \
      unzip \
      gdal-bin \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /data/import \
    && wget --quiet http://data.openstreetmapdata.com/water-polygons-split-3857.zip \
    && unzip -oj water-polygons-split-3857.zip -d /data/import \
    && rm water-polygons-split-3857.zip

RUN mkdir -p /data/import \
    && wget --quiet http://data.openstreetmapdata.com/simplified-water-polygons-complete-3857.zip \
    && unzip -oj simplified-water-polygons-complete-3857.zip -d /data/import \
    && rm simplified-water-polygons-complete-3857.zip

RUN mkdir -p /data/import \
    && wget http://naciscdn.org/naturalearth/packages/natural_earth_vector.sqlite.zip \
    && unzip -oj natural_earth_vector.sqlite.zip -d /data/import \
    && rm natural_earth_vector.sqlite.zip

ENV IMPORT_DATA_DIR=/data/import

COPY . /usr/src/app
WORKDIR /usr/src/app

CMD ["./import.sh"]

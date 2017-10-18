FROM osm2vectortiles/postgis

ENV IMPORT_DATA_DIR=/data/import \
    NATURAL_EARTH_DB=/data/import/natural_earth_vector.sqlite \
    LAKELINES_GEOJSON=/data/import/lake_centerline.geojson

RUN apt-get update && apt-get install -y --no-install-recommends \
      wget \
      unzip \
      gdal-bin \
      sqlite3 \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p $IMPORT_DATA_DIR \
    && wget --quiet http://data.openstreetmapdata.com/water-polygons-split-3857.zip \
    && unzip -oj water-polygons-split-3857.zip -d $IMPORT_DATA_DIR \
    && rm water-polygons-split-3857.zip

RUN wget --quiet http://data.openstreetmapdata.com/simplified-water-polygons-complete-3857.zip \
    && unzip -oj simplified-water-polygons-complete-3857.zip -d $IMPORT_DATA_DIR \
    && rm simplified-water-polygons-complete-3857.zip

COPY ./clean-natural-earth.sh /usr/src/app/
RUN wget --quiet http://naciscdn.org/naturalearth/packages/natural_earth_vector.sqlite.zip \
    && unzip -oj natural_earth_vector.sqlite.zip -d /data/import \
    && rm natural_earth_vector.sqlite.zip \
    && ./usr/src/app/clean-natural-earth.sh

RUN wget --quiet -L -P "$IMPORT_DATA_DIR" https://github.com/lukasmartinelli/osm-lakelines/releases/download/v0.9/lake_centerline.geojson

COPY . /usr/src/app
WORKDIR /usr/src/app

CMD ["./import.sh"]

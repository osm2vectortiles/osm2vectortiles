FROM mdillon/postgis:9.4

RUN apt-get update && apt-get install -y --no-install-recommends \
      wget \
      unzip \
      gdal-bin \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /data/import \
    && wget http://naciscdn.org/naturalearth/packages/natural_earth_vector.sqlite.zip \
    && unzip -oj natural_earth_vector.sqlite.zip -d /data/import \
    && rm natural_earth_vector.sqlite.zip

ENV NATURAL_EARTH_SQLITE_FILE=/data/import/natural_earth_vector.sqlite

RUN mkdir -p /usr/src/app
COPY import.sh /usr/src/app/
WORKDIR /usr/src/app

CMD ["./import.sh"]

FROM mdillon/postgis:9.4

RUN apt-get update && apt-get install -y --no-install-recommends \
      wget \
      ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV CARTODB_DIR=/opt/cartodb-postgresql
RUN mkdir -p "$CARTODB_DIR" \
 && wget -P "$CARTODB_DIR" --quiet "https://raw.githubusercontent.com/CartoDB/cartodb-postgresql/0.14.0/scripts-available/CDB_XYZ.sql"

RUN mkdir -p /opt/postgis-vt-util \
    && wget -P /opt/postgis-vt-util --quiet https://raw.githubusercontent.com/mapbox/postgis-vt-util/v1.0.0/postgis-vt-util.sql
ENV VT_UTIL_DIR=/opt/postgis-vt-util

# copy new initdb file which enables the hstore extension and Mapbox vt-util functions
RUN rm -f /docker-entrypoint-initdb.d/postgis.sh
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./initdb-osm.sh /docker-entrypoint-initdb.d/20_osm.sh

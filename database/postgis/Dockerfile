FROM mdillon/postgis:9.4

# download vt-util functions
ADD https://raw.githubusercontent.com/mapbox/postgis-vt-util/v1.0.0/postgis-vt-util.sql /opt/postgis-vt-util/
ENV VT_UTIL_DIR=/opt/postgis-vt-util

# copy new initdb file which enables the hstore extension and Mapbox vt-util functions
RUN rm -f /docker-entrypoint-initdb.d/postgis.sh
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./initdb-osm.sh /docker-entrypoint-initdb.d/20_osm.sh

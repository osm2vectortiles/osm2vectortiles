##### From https://github.com/gordlea/docker-postgis #####
FROM postgres:9.5

MAINTAINER "Gord Lea <jgordonlea@gmail.com>"

RUN apt-get update && apt-get install -y \
    build-essential \
    postgresql-server-dev-9.5 \
    libxml2-dev \
    libgdal-dev \
    libproj-dev \
    libjson0-dev \
    xsltproc \
    docbook-xsl \
    docbook-mathml \
    libpcre3-dev \
    cmake \
    libcgal-dev \
    openscenegraph \
    libopenscenegraph-dev \
    imagemagick \
    wget

#latest osgeo
RUN wget http://download.osgeo.org/geos/geos-3.5.0.tar.bz2; \
    tar xfj geos-3.5.0.tar.bz2; \
    cd geos-3.5.0; \
    ./configure; \
    make -j; \
    make install; \
    cd ..; \
    rm -rf geos-3.5.0*

RUN wget http://download.osgeo.org/postgis/source/postgis-2.2.0.tar.gz; \
    tar xvzf postgis-2.2.0.tar.gz; \
    cd postgis-2.2.0; \
    ./configure --with-raster --with-topology \
    make -j; \
    make install; \
    cd ..; \
    rm -rf postgis-2.2.0*

RUN ldconfig

#ADD update-pgconf.sh /docker-entrypoint-initdb.d/

############################################

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      wget \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

ENV CARTODB_DIR=/opt/cartodb-postgresql \
    VT_UTIL_DIR=/opt/postgis-vt-util \
    VT_UTIL_URL="https://raw.githubusercontent.com/mapbox/postgis-vt-util/v1.0.0/postgis-vt-util.sql"

RUN mkdir -p /opt/postgis-vt-util \
 && wget -P /opt/postgis-vt-util --quiet "$VT_UTIL_URL"

# install github.com/elitwin/pgtune 
RUN wget https://github.com/elitwin/pgtune/tarball/master \
   && tar -xzf master \
   && mv elitwin* pgtune \
   && rm -rf master

# copy new initdb file which enables the hstore extension and Mapbox vt-util functions
RUN rm -f /docker-entrypoint-initdb.d/postgis.sh
#COPY ./osmdw_pgtune.sh /docker-entrypoint-initdb.d/05_osmdw_pgtune.sh
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./initdb-osm.sh /docker-entrypoint-initdb.d/20_osm.sh

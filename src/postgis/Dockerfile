FROM postgres:9.5
MAINTAINER "Lukas Martinelli <me@lukasmartinelli.ch>"
ENV POSTGIS_MAJOR=2.2 \
    POSTGIS_VERSION=2.2.2 \
    GEOS_VERSION=3.5.0

RUN apt-get -y update \
 && apt-get -y --no-install-recommends install \
        curl \
        build-essential cmake \
        # PostGIS build dependencies
		postgresql-server-dev-$PG_MAJOR libxml2-dev libjson0-dev libproj-dev libgdal-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/geos
RUN curl -o /opt/geos.tar.bz2 http://download.osgeo.org/geos/geos-$GEOS_VERSION.tar.bz2 \
 && tar xf /opt/geos.tar.bz2 -C /opt/geos/ --strip-components=1 \
 && ./configure \
 && make -j \
 && make install \
 && rm -rf /opt/geos*

WORKDIR /opt/postgis
RUN curl -o /opt/postgis.tar.gz http://download.osgeo.org/postgis/source/postgis-$POSTGIS_VERSION.tar.gz \
 && tar xf /opt/postgis.tar.gz -C /opt/postgis --strip-components=1 \
 && ./configure --with-raster --with-topology \
 && make \
 && make install \
 && ldconfig

 ##&& (cd /opt/postgis/extensions/postgis && make -j && make install) \
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh

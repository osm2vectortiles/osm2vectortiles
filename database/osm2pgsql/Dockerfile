FROM debian:wheezy
MAINTAINER Lukas Martinelli <me@lukasmartinelli.ch>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    g++ \
    git-core \
    libboost-dev \
    libboost-filesystem-dev \
    libboost-system-dev \
    libboost-thread-dev \
    libbz2-dev \
    libgeos++-dev \
    libgeos-dev \
    liblua5.2-dev \
    libpq-dev \
    libproj-dev \
    libprotobuf-c0-dev \
    libtool \
    libxml2-dev \
    lua5.2 \
    make \
    protobuf-c-compiler &&\
    rm -rf /var/lib/apt/lists/*

ENV HOME /root
ENV OSM2PGSQL_VERSION 0.87.2

RUN mkdir src &&\
    cd src &&\
    git clone --depth 1 --branch $OSM2PGSQL_VERSION https://github.com/openstreetmap/osm2pgsql.git &&\
    cd osm2pgsql &&\
    ./autogen.sh &&\
    ./configure &&\
    make &&\
    make install &&\
    cd /root &&\
    rm -rf src

COPY import.sh /usr/src/app/
WORKDIR /usr/src/app

VOLUME /data/import
ENV IMPORT_DATA_DIR=/data/import

VOLUME /data/cache
ENV CACHE_DIR=/data/cache

CMD ["./import.sh"]

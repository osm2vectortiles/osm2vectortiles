FROM ubuntu:14.04

ENV IMPOSM_VERSION 32623ccce097584be79ec8617dfae42d595ac2b8
ENV DEBIAN_FRONTEND=noninteractive

# Build imposm3 binary and clean up afterwards
RUN mkdir -p /usr/src/app
RUN apt-get update && \
    apt-get install -y golang \
     git \
     libgeos++-dev \
     libleveldb-dev \
     libprotobuf-dev \
     libsqlite3-dev \
     mercurial \
     curl

RUN mkdir -p /opt/imposm \
    && git clone https://github.com/omniscale/imposm3 /opt/imposm/src/imposm3 \
    && cd /opt/imposm/src/imposm3 \
    && git checkout $IMPOSM_VERSION \
    && GOPATH=/opt/imposm go get imposm3 \
    && GOPATH=/opt/imposm go build -o /usr/src/app/imposm3 imposm3 \
    && cd / \
    && rm -rf /opt/imposm \

RUN apt-get purge -y --auto-remove golang git mercurial
ENV IMPOSM_BIN=/usr/src/app/imposm

COPY import.sh /usr/src/app
COPY mapping.json /usr/src/app
ENV MAPPING_JSON=/usr/src/app/mapping.json
WORKDIR /usr/src/app

VOLUME /data
ENV DATA_DIR=/data

CMD ["./import.sh"]

FROM golang:1.4

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      libprotobuf-dev libleveldb-dev libgeos-dev \
      --no-install-recommends
RUN ln -s /usr/lib/libgeos_c.so /usr/lib/libgeos.so

WORKDIR $GOPATH
RUN go get github.com/omniscale/imposm3 \
    && go install github.com/omniscale/imposm3

ENV IMPOSM_BIN=imposm3

RUN mkdir -p /usr/src/app
COPY import.sh /usr/src/app/
COPY mapping.json /usr/src/app/
ENV MAPPING_JSON=/usr/src/app/mapping.json
WORKDIR /usr/src/app

VOLUME /data/import
ENV IMPORT_DATA_DIR=/data/import

VOLUME /data/cache
ENV IMPOSM_CACHE_DIR=/data/cache

CMD ["./import.sh"]

FROM golang:1.4

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      libprotobuf-dev libleveldb-dev libgeos-dev \
      --no-install-recommends
RUN ln -s /usr/lib/libgeos_c.so /usr/lib/libgeos.so

WORKDIR $GOPATH
RUN go get github.com/omniscale/imposm3 \
    && go install github.com/omniscale/imposm3

# Purge no longer needed packages to keep image small.
# Protobuf and LevelDB dependencies cannot be removed
# because they are dynamically linked.
RUN apt-get purge -y --auto-remove \
    g++ gcc libc6-dev make git \
    && rm -rf /var/lib/apt/lists/*

VOLUME /data/import /data/cache
ENV IMPORT_DATA_DIR=/data/import \
    IMPOSM_CACHE_DIR=/data/cache \
    MAPPING_YAML=/usr/src/app/mapping.yml \
    IMPOSM_BIN=imposm3

RUN mkdir -p /usr/src/app
COPY . /usr/src/app/
WORKDIR /usr/src/app

CMD ["./import.sh"]

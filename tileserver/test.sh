#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

cwd=$(pwd)

function serve_vector_tiles_sample() {
    local container_name="vector-tiles-sample-test"
    local dir=`mktemp -d` && cd $dir

    wget https://github.com/klokantech/vector-tiles-sample/archive/v1.0.tar.gz
    tar -xzvf v1.0.tar.gz
    cd vector-tiles-sample-1.0
    rm -rf countries.tm2source
    wget https://github.com/klokantech/vector-tiles-sample/releases/download/v1.0/countries.mbtiles

    docker rm -f "$container_name"
    docker run -d --name "$container_name" -p 80:80 -v $(pwd):/data osm2vectortiles/tileserver
    sleep 5 # make sure server is up
    curl "http://localhost:80/index.json"
    docker stop "$container_name"

    rm -rf $dir
    cd $cwd
}

serve_vector_tiles_sample

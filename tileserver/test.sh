#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

cwd=$(pwd)

function serve_vector_tiles_sample() {
    # prepare sample data
    wget https://github.com/klokantech/vector-tiles-sample/archive/v1.0.tar.gz
    tar -xzvf v1.0.tar.gz
    cd vector-tiles-sample-1.0
    rm -rf countries.tm2source
    wget https://github.com/klokantech/vector-tiles-sample/releases/download/v1.0/countries.mbtiles

    docker run -d --name vector-tiles-sample-test -p 80:80 -v $(pwd):/data osm2vectortiles/tileserver
    docker rm -rf vector-tiles-sample-test
    curl localhost:80/index.json
}

serve_vector_tiles_sample

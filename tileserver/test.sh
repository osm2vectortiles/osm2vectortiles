#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

cwd=$(pwd)

function serve_vector_tiles_sample() {
    local container_name="vector-tiles-sample-test"
    local repository_name="osm2vectortiles/tileserver"
    local dir=`mktemp -d` && cd $dir

    echo "Download vector-tiles-sample"
    wget --quiet https://github.com/klokantech/vector-tiles-sample/archive/v1.0.tar.gz
    tar -xzf v1.0.tar.gz
    cd vector-tiles-sample-1.0
    rm -rf countries.tm2source
    wget --quiet https://github.com/klokantech/vector-tiles-sample/releases/download/v1.0/countries.mbtiles

    docker rm -f "$container_name" > /dev/null
    echo "Start $repository_name"
    docker run -d --name "$container_name" -p 80:80 -v $(pwd):/data "$repository_name" > /dev/null
    echo "Wait until $repository_name is up"
    sleep 5 # make sure server is up
    echo "Fetch TileJSON url"
    curl "http://localhost:80/index.json"
    docker stop "$container_name"

    rm -rf $dir
    cd $cwd
}

serve_vector_tiles_sample

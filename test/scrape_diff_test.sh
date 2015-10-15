#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly LOCAL_DIR="$CWD/local"
readonly MAPBOX_DIR="$CWD/mapbox"
readonly DIFF_DIR="$CWD/diff"
readonly LOCAL_BASE_URL="http://localhost:8080"

readonly MAPBOX_OSM_BRIGHT_ID="morgenkaffee.9c069ced"
readonly MAPBOX_BASE_URL="https://api.mapbox.com/v4/$MAPBOX_OSM_BRIGHT_ID"
readonly MAPBOX_ACCESS_TOKEN="pk.eyJ1IjoibW9yZ2Vua2FmZmVlIiwiYSI6ImNpZnNpMHRyMzAwazB0Nm03c2syeXV3ZzgifQ.FtkzQBLU67QvhJu1M-7xbw"

readonly PIXELMATCH_BIN="pixelmatch"

function download_tile() {
    local base_url=$1
    local q=$2
    local z=$3
    local x=$4
    local y=$5
    echo "$base_url/$z/$x/$y.png$q"
    curl -o $z"_"$x"_"$y.png "$base_url/$z/$x/$y.png$q"
}

function download_tiles_from_local() {
    mkdir -p $LOCAL_DIR
    cd $LOCAL_DIR
    download_tile $LOCAL_BASE_URL "" 15 17161 11475
    download_tile $LOCAL_BASE_URL "" 13 4290 2868
    download_tile $LOCAL_BASE_URL "" 12 2145 1434
    download_tile $LOCAL_BASE_URL "" 11 1072 717
    download_tile $LOCAL_BASE_URL "" 10 536 358
    download_tile $LOCAL_BASE_URL "" 9 268 179
    cd $CWD
}

function download_tiles_from_mapbox() {
    mkdir -p $MAPBOX_DIR
    cd $MAPBOX_DIR
    local q="?access_token=$MAPBOX_ACCESS_TOKEN"
    download_tile $MAPBOX_BASE_URL "$q" 15 17161 11475
    download_tile $MAPBOX_BASE_URL "$q" 13 4290 2868
    download_tile $MAPBOX_BASE_URL "$q" 12 2145 1434
    download_tile $MAPBOX_BASE_URL "$q" 11 1072 717
    download_tile $MAPBOX_BASE_URL "$q" 10 536 358
    download_tile $MAPBOX_BASE_URL "$q" 9 268 179
    cd $CWD
}

function make_diffs() {
    mkdir -p $DIFF_DIR
    cd $MAPBOX_DIR

    local filepath
    for filepath in "$LOCAL_DIR"/*.png; do
        local filename=$(basename "$filepath")
        $PIXELMATCH_BIN $LOCAL_DIR/$filename $MAPBOX_DIR/$filename $DIFF_DIR/$filename 0.005 1
    done

    cd $CWD
}

download_tiles_from_mapbox
download_tiles_from_local
make_diffs

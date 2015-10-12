#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
readonly IMPOSM_CACHE_DIR=${IMPOSM_CACHE_DIR:-/data/cache}

readonly IMPOSM_BIN=${IMPOSM_BIN:-/imposm3}
readonly MAPPING_JSON=${MAPPING_JSON:-/usr/src/app/mapping.json}

readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

readonly DB_SCHEMA=${OSM_SCHEMA:-public}
readonly DB_HOST=$DB_PORT_5432_TCP_ADDR
readonly PG_CONNECT="postgis://$OSM_USER:$OSM_PASSWORD@$DB_HOST/$OSM_DB"

function read_pbf_into_cache() {
    local pbf_file=$1
    $IMPOSM_BIN import -connection $PG_CONNECT -mapping $MAPPING_JSON -appendcache -cachedir=$IMPOSM_CACHE_DIR -read $pbf_file
}

function import_from_cache() {
    $IMPOSM_BIN import -connection $PG_CONNECT -mapping $MAPPING_JSON -appendcache -cachedir=$IMPOSM_CACHE_DIR -write -diff -dbschema-import=${DB_SCHEMA}
}

function main() {
    if [ "$(ls -A $IMPORT_DATA_DIR/*.pbf 2> /dev/null)" ]; then
        local pbf_file
        for pbf_file in "$IMPORT_DATA_DIR"/*.pbf; do
            read_pbf_into_cache $pbf_file
            import_from_cache
        done
    else
        echo "No PBF files for import found."
        echo "Please mount the $IMPORT_DATA_DIR volume to a folder containing OSM PBF files."
        exit 404
    fi

    if ! [ "$(ls -A $IMPORT_DATA_DIR)" ]; then
        echo "To speed up imposm import over subsequent runs you should mount the $IMPOSM_CACHE_DIR to a empty folder."
    fi
}

main


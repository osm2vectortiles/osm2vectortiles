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

function download_pbf() {
    local pbf_url=$1
	wget -q  --directory-prefix "$IMPORT_DATA_DIR" --no-clobber "$pbf_url"
}

function import_pbf() {
    local pbf_file="$1"
    exec $IMPOSM_BIN import \
        -connection $PG_CONNECT \
        -mapping $MAPPING_YAML \
        -overwritecache -cachedir=$IMPOSM_CACHE_DIR \
        -read $pbf_file \
        -write -dbschema-import=${DB_SCHEMA} -optimize -diff
}

function import_diff_changes() {
    local changes_dir="$1"
    exec $IMPOSM_BIN diff \
        -connection $PG_CONNECT \
        -mapping $MAPPING_YAML \
        -cachedir=$IMPOSM_CACHE_DIR \
        -dbschema-import=${DB_SCHEMA} $changes_dir/*.osc.gz
}

function import_single_pbf() {
    if [ "$(ls -A $IMPORT_DATA_DIR/*.pbf 2> /dev/null)" ]; then
        local pbf_file
        for pbf_file in "$IMPORT_DATA_DIR"/*.pbf; do
            import_pbf $pbf_file
            break
        done
        exit 0
    else
        echo "No PBF files for import found."
        echo "Please mount the $IMPORT_DATA_DIR volume to a folder containing OSM PBF files."
        exit 404
    fi
}

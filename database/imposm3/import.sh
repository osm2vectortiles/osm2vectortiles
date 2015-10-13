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

function import_pbf() {
    local pbf_file=$1
    $IMPOSM_BIN import -connection $PG_CONNECT -mapping $MAPPING_JSON \
        -overwritecache -cachedir=$IMPOSM_CACHE_DIR \
        -read $pbf_file \
        -write -diff -dbschema-import=${DB_SCHEMA} -optimize
}

function import_change() {
    local changes_file=$1
    $IMPOSM_BIN diff -connection $PG_CONNECT -mapping $MAPPING_JSON \
        -appendcache -cachedir=$IMPOSM_CACHE_DIR \
        -dbschema-import=${DB_SCHEMA} \
        $changes_file
}

function check_persistent_cache_dir() {
    if ! [ "$(ls -A $IMPOSM_CACHE_DIR)" ]; then
        echo "To support importing OSM chage files you should mount the $IMPOSM_CACHE_DIR to a persistent folder."
        exit 400
    fi
}

function import_all_changes() {
    if [ "$(ls -A $IMPORT_DATA_DIR/*osc.gz 2> /dev/null)" ]; then
        echo "OSM change files found. Only changes are imported, initial import is skipped."

        local change_file
        for change_file in "$IMPORT_DATA_DIR"/*.osc.gz; do
            import_change $change_file
        done
        exit 0
    fi
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

function main() {
    check_persistent_cache_dir
    import_all_changes
    import_single_pbf
}

main

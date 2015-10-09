#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
IMPOSM_CACHE_DIR=${IMPOSM_CACHE_DIR:-/data/cache}

IMPOSM_BIN=${IMPOSM_BIN:-/imposm3}
MAPPING_JSON=${MAPPING_JSON:-/usr/src/app/mapping.json}

OSM_DB=${OSM_DB:-osm}
OSM_USER=${OSM_USER:-osm}
OSM_PASSWORD=${OSM_PASSWORD:-osm}

DB_SCHEMA=public
PG_CONNECT="postgis://$OSM_USER:$OSM_PASSWORD@$DB_PORT_5432_TCP_ADDR/$OSM_DB"

if [ "$(ls -A $IMPORT_DATA_DIR/*.pbf 2> /dev/null)" ]; then
    for PBF_FILE in "$IMPORT_DATA_DIR"/*.pbf; do
        $IMPOSM_BIN import -connection $PG_CONNECT -mapping $MAPPING_JSON -overwritecache -cachedir=$IMPOSM_CACHE_DIR -read $PBF_FILE -write -dbschema-import=${DB_SCHEMA}
    done
else
    echo "No PBF files for import found."
    echo "Please mount the $IMPORT_DATA_DIR volume to a folder containing OSM PBF files."
    exit 404
fi

if ! [ "$(ls -A $IMPORT_DATA_DIR)" ]; then
    echo "To speed up imposm import over subsequent runs you should mount the $IMPOSM_CACHE_DIR to a empty folder."
fi

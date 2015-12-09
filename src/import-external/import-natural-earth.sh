#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

source sql.sh

readonly IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
readonly NATURAL_EARTH_SQLITE_FILE="$IMPORT_DATA_DIR/natural_earth_vector.sqlite"

function import_natural_earth() {
    echo "Importing Natural Earth to PostGIS"
    PGCLIENTENCODING=LATIN1 ogr2ogr \
    -progress \
    -f Postgresql \
    -s_srs EPSG:4326 \
    -t_srs EPSG:3857 \
    -clipsrc -180.1 -85.0511 180.1 85.0511 \
    PG:"dbname=$OSM_DB user=$OSM_USER host=$DB_HOST port=$DB_PORT" \
    -lco GEOMETRY_NAME=geom \
    -lco DIM=2 \
    -nlt GEOMETRY \
    -overwrite \
    "$NATURAL_EARTH_SQLITE_FILE"
}

import_natural_earth

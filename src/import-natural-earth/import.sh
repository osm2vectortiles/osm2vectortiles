#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly DB_HOST=$DB_PORT_5432_TCP_ADDR
readonly DB_PORT=$DB_PORT_5432_TCP_PORT
readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

function import_sqlite() {
    echo "Importing Natural Earth to PostGIS..."
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

import_sqlite

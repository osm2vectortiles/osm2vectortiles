#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

source sql.sh

readonly COUNTRIES_GEOJSON="countries.geojson"
readonly STATES_GEOJSON="states.geojson"
readonly SEAS_GEOJSON="seas.geojson"

function import_geojson() {
    local geojson_file=$1
    local table_name=$2

    drop_table "$table_name"
    echo "$geojson_file"

    PGCLIENTENCODING=UTF8 ogr2ogr \
    -f Postgresql \
    -s_srs EPSG:4326 \
    -t_srs EPSG:3857 \
    PG:"$PGCONN" \
    "$geojson_file" \
    -nln "$table_name"
}

function import_labels() {
    echo "Inserting labels into $OSM_DB"

    import_geojson "$SEAS_GEOJSON" "custom_seas"
    import_geojson "$STATES_GEOJSON" "custom_states"
    import_geojson "$COUNTRIES_GEOJSON" "custom_countries"
}

import_labels

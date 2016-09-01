#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
readonly IMPOSM_CACHE_DIR=${IMPOSM_CACHE_DIR:-/data/cache}

readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

readonly DB_SCHEMA=${OSM_SCHEMA:-public}
readonly DB_HOST=$DB_PORT_5432_TCP_ADDR
readonly PG_CONNECT="postgis://$OSM_USER:$OSM_PASSWORD@$DB_HOST/$OSM_DB"

function import_pbf() {
    local pbf_file="$1"
    echo "Importing in diff mode"
    imposm3 import \
        -connection "$PG_CONNECT" \
        -mapping "$MAPPING_YAML" \
        -overwritecache \
        -cachedir "$IMPOSM_CACHE_DIR" \
        -read "$pbf_file" \
        -dbschema-import="${DB_SCHEMA}" \
        -write -optimize -diff

    create_osm_water_point_table
    update_points
    subdivide_polygons
    update_scaleranks
}

function update_points() {
    echo "Update osm_place_polygon with point geometry"
    exec_sql_file "point_update.sql"
}

function update_scaleranks() {
    echo "Update scaleranks from Natural Earth data"
    exec_sql_file "update_scaleranks.sql"
}

function create_osm_water_point_table() {
    echo "Create osm_water_point table with precalculated centroids"
    exec_sql_file "water_point_table.sql"
}

function subdivide_polygons() {
    echo "Subdividing polygons in $OSM_DB"
    exec_sql_file "subdivide_polygons.sql"
}

function exec_sql_file() {
    local sql_file=$1
    PG_PASSWORD=$OSM_PASSWORD psql \
        --host="$DB_HOST" \
        --port=5432 \
        --dbname="$OSM_DB" \
        --username="$OSM_USER" \
        -v ON_ERROR_STOP=1 \
        -a -f "$sql_file"
}

function import_pbf_diffs() {
    local diffs_file="$1"
    local tile_list="$2"

    echo "Import changes from $diffs_file"
    imposm3 diff \
        -tilelist "$tile_list" \
        -maxzoom "14" \
        -connection "$PG_CONNECT" \
        -mapping "$MAPPING_YAML" \
        -cachedir "$IMPOSM_CACHE_DIR" \
        -diffdir "$IMPORT_DATA_DIR" \
        -dbschema-import "${DB_SCHEMA}" \
        "$diffs_file"

    create_osm_water_point_table
    update_points
    subdivide_polygons
}

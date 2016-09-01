#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly PG_CONNECT="postgis://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB"

function import_pbf() {
    local pbf_file="$1"
    echo "Importing in diff mode"
    imposm3 import \
        -connection "$PG_CONNECT" \
        -mapping "$MAPPING_YAML" \
        -overwritecache \
        -cachedir "$IMPOSM_CACHE_DIR" \
        -read "$pbf_file" \
        -deployproduction \
        -write -optimize -diff

    create_osm_water_point_table
    update_points
    subdivide_polygons
    update_scaleranks
}

function exec_sql_file() {
    local file_name="$1"
    PGPASSWORD="$POSTGRES_PASSWORD" psql \
        -v ON_ERROR_STOP=1 \
        --host="$POSTGRES_HOST" \
        --port="5432" \
        --dbname="$POSTGRES_DB" \
        --username="$POSTGRES_USER" \
        -f "$file_name"
}

function update_points() {
    echo "Update osm_place_polygon with point geometry"
    exec_sql_file "point_update.sql"
}

function update_scaleranks() {
    echo "Update scaleranks from Natural Earth data"
    exec_sql_file "update_scaleranks.sql" || echo 'No NaturalEarth data found in database' && exit 500
}

function create_osm_water_point_table() {
    echo "Create osm_water_point table with precalculated centroids"
    exec_sql_file "water_point_table.sql"
}

function subdivide_polygons() {
    echo "Subdividing polygons"
    exec_sql_file "subdivide_polygons.sql"
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
        -diffdir "$IMPOSM_DIFF_DIR" \
        "$diffs_file"

    create_osm_water_point_table
    update_points
    subdivide_polygons
}

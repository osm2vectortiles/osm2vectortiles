#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
readonly IMPOSM_CACHE_DIR=${IMPOSM_CACHE_DIR:-/data/cache}
readonly TILELIST=${TILELIST:-/data/export/tiles.txt}
readonly DIFFS=${DIFFS:-true}

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
    echo "Importing in diff mode"
    imposm3 import \
        -connection "$PG_CONNECT" \
        -mapping "$MAPPING_YAML" \
        -overwritecache \
        -cachedir "$IMPOSM_CACHE_DIR" \
        -read "$pbf_file" \
        -dbschema-import="${DB_SCHEMA}" \
        -write -optimize -diff

    echo "Create osm_water_point table with precalculated centroids"
    create_osm_water_point_table

    echo "Update osm_place_polygon with point geometry"
    update_points

    echo "Subdividing polygons in $OSM_DB"
    subdivide_polygons

    echo "Update scaleranks from Natural Earth data"
    update_scaleranks
}

function update_points() {
    exec_sql_file "point_update.sql"
}

function update_scaleranks() {
    exec_sql_file "update_scaleranks.sql"
}

function create_osm_water_point_table() {
    exec_sql_file "water_point_table.sql"
}

function subdivide_polygons() {
    exec_sql_file "subdivide_polygons.sql"
}

function update_scaleranks() {
    exec_sql_file "update_scaleranks.sql"
}

function exec_sql() {
	local sql_cmd="$1"
	PG_PASSWORD=$OSM_PASSWORD psql \
        --host="$DB_HOST" \
        --port=5432 \
        --dbname="$OSM_DB" \
        --username="$OSM_USER" \
        -c "$sql_cmd"
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
    local pbf_file="$1"
    local diffs_file="$IMPORT_DATA_DIR/latest.osc.gz"

    echo "Import changes from $diffs_file"
    imposm3 diff \
        -tilelist "$TILELIST" \
        -maxzoom "14" \
        -connection "$PG_CONNECT" \
        -mapping "$MAPPING_YAML" \
        -cachedir "$IMPOSM_CACHE_DIR" \
        -diffdir "$IMPORT_DATA_DIR" \
        -dbschema-import "${DB_SCHEMA}" \
        "$diffs_file"

    echo "Create osm_water_point table with precalculated centroids"
    create_osm_water_point_table

    echo "Update osm_place_polygon with point geometry"
    update_points

    echo "Subdividing polygons in $OSM_DB"
    subdivide_polygons
}

#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly SOURCE_PROJECT_DIR=${SOURCE_PROJECT_DIR:-/data/tm2source}
readonly EXPORT_DIR=${EXPORT_DIR:-/data/export}

readonly OSM_HOST=$DB_PORT_5432_TCP_ADDR
readonly OSM_PORT=$DB_PORT_5432_TCP_PORT
readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

readonly DB_SCHEMA=public

readonly MIN_ZOOM=${MIN_ZOOM:-0}
readonly MAX_ZOOM=${MAX_ZOOM:-14}
readonly BBOX=${BBOX:-"-180, -85.0511, 180, 85.0511"}

readonly DEST_PROJECT_DIR="/project"
readonly DEST_PROJECT_FILE="${DEST_PROJECT_DIR%%/}/data.yml"

# project config will be copied to new folder because we
# modify the source configuration
function copy_source_project() {
    cp -rf "$SOURCE_PROJECT_DIR" "$DEST_PROJECT_DIR"
}

# project.yml is single source of truth, therefore the mapnik
# stylesheet is not necessary
function cleanup_dest_project() {
    rm -f "${DEST_PROJECT_DIR%%/}/project.xml"
}

# replace database connection with postgis container connection
function replace_db_connection() {
    local replace_expr_1="s|host: .*|host: \"$OSM_HOST\"|g"
    local replace_expr_2="s|port: .*|port: \"$OSM_PORT\"|g"
    local replace_expr_3="s|dbname: .*|dbname: \"$OSM_DB\"|g"
    local replace_expr_4="s|user: .*|user: \"$OSM_USER\"|g"
    local replace_expr_5="s|password: .*|password: \"$OSM_PASSWORD\"|g"

    sed -i "$replace_expr_1" "$DEST_PROJECT_FILE"
    sed -i "$replace_expr_2" "$DEST_PROJECT_FILE"
    sed -i "$replace_expr_3" "$DEST_PROJECT_FILE"
    sed -i "$replace_expr_4" "$DEST_PROJECT_FILE"
    sed -i "$replace_expr_5" "$DEST_PROJECT_FILE"
}

function export_mbtiles() {
    local mbtiles_name=="tiles.mbtiles"
    local source="tmsource://$DEST_PROJECT_DIR"
    local sink="mbtiles://$EXPORT_DIR/$mbtiles_name"
    exec tl copy -b "$BBOX" --min-zoom $MIN_ZOOM --max-zoom $MAX_ZOOM $source $sink
}

function main() {
    copy_source_project
    cleanup_dest_project
    replace_db_connection
    export_mbtiles
}

main

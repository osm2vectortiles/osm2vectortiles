#!/bin/bash
set -o errexit
set -o pipefail

readonly SOURCE_PROJECT_DIR=${SOURCE_PROJECT_DIR:-/data/tm2source}
readonly EXPORT_DIR=${EXPORT_DIR:-/data/export}

readonly DEST_PROJECT_DIR="/tmp/project"
readonly DEST_PROJECT_FILE="${DEST_PROJECT_DIR%%/}/data.yml"

readonly OSM_HOST=$DB_PORT_6432_TCP_ADDR
readonly OSM_PORT=$DB_PORT_6432_TCP_PORT
readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

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

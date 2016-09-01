#!/bin/bash
set -o errexit
set -o pipefail

readonly DEST_PROJECT_DIR="/tmp/project"
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
    local replace_expr_1="s|host: .*|host: \"$POSTGRES_HOST\"|g"
    local replace_expr_2="s|port: .*|port: \"5432\"|g"
    local replace_expr_3="s|dbname: .*|dbname: \"$POSTGRES_USER\"|g"
    local replace_expr_4="s|user: .*|user: \"$POSTGRES_DB\"|g"
    local replace_expr_5="s|password: .*|password: \"$POSTGRES_PASSWORD\"|g"

    sed -i "$replace_expr_1" "$DEST_PROJECT_FILE"
    sed -i "$replace_expr_2" "$DEST_PROJECT_FILE"
    sed -i "$replace_expr_3" "$DEST_PROJECT_FILE"
    sed -i "$replace_expr_4" "$DEST_PROJECT_FILE"
    sed -i "$replace_expr_5" "$DEST_PROJECT_FILE"
}

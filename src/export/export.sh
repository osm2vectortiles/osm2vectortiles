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

readonly RENDER_SCHEME=${RENDER_SCHEME:-pyramid}
readonly MIN_ZOOM=${MIN_ZOOM:-0}
readonly MAX_ZOOM=${MAX_ZOOM:-14}
readonly BBOX=${BBOX:-"-180, -85.0511, 180, 85.0511"}

readonly DEST_PROJECT_DIR="/tmp/project"
readonly DEST_PROJECT_FILE="${DEST_PROJECT_DIR%%/}/data.yml"

readonly QUEUE_NAME=${QUEUE_NAME:-osm2vectortiles_jobs}
readonly BUCKET_NAME=${BUCKET_NAME:-osm2vectortiles-jobs}

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
    local mbtiles_name="tiles.mbtiles"

    if [ -z "$AWS_ACCESS_KEY_ID" ]; then
        exec python export.py local "$EXPORT_DIR/$mbtiles_name" \
            --tm2source="$DEST_PROJECT_DIR" \
            --bbox="$BBOX" \
            --min_zoom="$MIN_ZOOM" \
            --max_zoom="$MAX_ZOOM" \
            --render_scheme="$RENDER_SCHEME"
    else
        echo "Using AWS SQS to work through jobs"
        exec python export.py remote "$QUEUE_NAME" \
            --tm2source="$DEST_PROJECT_DIR" \
            --bucket="$BUCKET_NAME" \
            --render_scheme="$RENDER_SCHEME"
    fi
}

function main() {
    copy_source_project
    cleanup_dest_project
    replace_db_connection
    export_mbtiles
}

main

#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

source utils.sh

readonly QUEUE_NAME=${QUEUE_NAME:-osm2vectortiles_jobs}
readonly BUCKET_NAME=${BUCKET_NAME:-osm2vectortiles-jobs}

function export_remote_mbtiles() {
    export AWS_DEFAULT_REGION="$AWS_REGION"
    exec python export_remote.py "$QUEUE_NAME" \
        --tm2source="$DEST_PROJECT_DIR" \
        --bucket="$BUCKET_NAME" \
        --render_scheme="$RENDER_SCHEME"
}

function main() {
    copy_source_project
    cleanup_dest_project
    replace_db_connection
    export_remote_mbtiles
}

main

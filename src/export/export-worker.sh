#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

source utils.sh

readonly QUEUE_NAME=${QUEUE_NAME:-osm2vectortiles_jobs}
readonly BUCKET_NAME=${BUCKET_NAME:-osm2vectortiles-jobs}
readonly RABBITMQ_URI=${RABBITMQ_URI:-"amqp://osm:osm@rabbitmq:5672/"}

function export_remote_mbtiles() {
    export AWS_DEFAULT_REGION="$AWS_REGION"
    exec python export_remote.py "$RABBITMQ_URI" \
        --tm2source="$DEST_PROJECT_DIR" \
        --bucket="$BUCKET_NAME"
}

function main() {
    copy_source_project
    cleanup_dest_project
    replace_db_connection
    export_remote_mbtiles
}

main

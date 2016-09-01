#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

source utils.sh

readonly BUCKET_NAME=${AWS_S3_JOB_BUCKET_NAME:-osm2vectortiles-jobs}
readonly RABBITMQ_URI=${RABBITMQ_URI:-"amqp://osm:osm@rabbitmq:5672/?blocked_connection_timeout=1200&heartbeat=0"}

function export_remote_mbtiles() {
    exec python -u export_remote.py "$RABBITMQ_URI" \
        --tm2source="$DEST_PROJECT_DIR" \
        --bucket="$"
}

function main() {
    copy_source_project
    cleanup_dest_project
    replace_db_connection
    export_remote_mbtiles
}

main

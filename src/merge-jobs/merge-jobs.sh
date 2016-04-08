#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly EXPORT_DIR=${EXPORT_DIR:-/data/export}
readonly MERGE_TARGET=${MERGE_TARGET:-"$EXPORT_DIR/planet.mbtiles"}
readonly RABBITMQ_URI=${RABBITMQ_URI:-"amqp://osm:osm@rabbitmq:5672/"}

function export_remote_mbtiles() {
    exec python merge-jobs.py "$RABBITMQ_URI" \
        --merge-target="$MERGE_TARGET"
}

export_remote_mbtiles

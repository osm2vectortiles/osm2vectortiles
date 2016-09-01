#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly MERGE_TARGET=${MERGE_TARGET:-"$MERGE_DIR/planet.mbtiles"}
readonly RABBITMQ_URI=${RABBITMQ_URI:-"amqp://osm:osm@rabbitmq:5672/?blocked_connection_timeout=1200&heartbeat=0"}

function export_remote_mbtiles() {
    exec python -u merge-jobs.py "$RABBITMQ_URI" \
        --merge-target="$MERGE_TARGET"
}

export_remote_mbtiles

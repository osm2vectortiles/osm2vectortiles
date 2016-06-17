#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly AMQP_URI=${AMQP_URI:-"amqp://osm:osm@rabbitmq:5672/"}
readonly EXPORT_DATA_DIR=${EXPORT_DATA_DIR:-"/data/export"}

function generate_list_jobs() {
    local unsorted_tiles="$EXPORT_DATA_DIR/tiles.txt"
    local sorted_tiles="$EXPORT_DATA_DIR/tiles.sorted.txt"
    local batched_jobs="$EXPORT_DATA_DIR/batched_jobs.json"
    local jobs_queue="jobs"

    python calculate_quad_key.py "$unsorted_tiles" | sort -k2 | cut -d ' ' -f1 > $sorted_tiles
    python generate_jobs.py list "$sorted_tiles" --batch-size=1000 > $batched_jobs

    pipecat publish --amqpuri="$AMQP_URI" "$jobs_queue" < $batched_jobs
}

generate_list_jobs

#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly AMQP_URI=${AMQP_URI:-"ampq://osm:osm@rabbitmq:5672/"}
readonly EXPORT_DATA_DIR=${EXPORT_DATA_DIR:-"/data/export"}

function generate_list_jobs() {
    local unsorted_jobs_file="$EXPORT_DATA_DIR/jobs.txt"
    local sorted_jobs_file="$EXPORT_DATA_DIR/sorted_jobs.txt"
    local batched_jobs_file="$EXPORT_DATA_DIR/batched_jobs.json"
    local jobs_queue="jobs"

    python calculate_quad_key.py "$unsorted_jobs_file" | sort -k2 | cut -d ' ' -c1 > $sorted_jobs_file
    python generate_jobs.py list "$sorted_jobs_file" --batch-size=1000 > $batched_jobs_file

    AMQP_URI="$AMQP_URI" pipecat publish "$jobs_queue" < $batched_jobs_file
}

generate_list_jobs

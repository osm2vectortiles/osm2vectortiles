#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly AMQP_URI=${AMQP_URI:-"ampq://osm:osm@rabbitmq:5672/"}
readonly EXPORT_DATA_DIR=${EXPORT_DATA_DIR:-"/data/export"}

function generate_world_jobs() {
    local jobs_file="$EXPORT_DATA_DIR/world_jobs.txt"
    local jobs_queue="jobs"

    python generate_jobs.py pyramid 0 0 0 --job-zoom=8 > $jobs_file
    AMQP_URI="$AMQP_URI" pipecat publish "$jobs_queue" < $jobs_file
}

generate_world_jobs

#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly AMQP_URI=${AMQP_URI:-"amqp://osm:osm@rabbitmq:5672/"}
readonly EXPORT_DATA_DIR=${EXPORT_DATA_DIR:-"/data/export"}
readonly TILE_X=${TILE_X:-"0"}
readonly TILE_Y=${TILE_Y:-"0"}
readonly TILE_Z=${TILE_Z:-"0"}
readonly JOB_ZOOM=${JOB_ZOOM:-"8"}

function generate_world_jobs() {
    local jobs_file="$EXPORT_DATA_DIR/world_jobs.txt"
    local jobs_queue="jobs"

    python generate_jobs.py pyramid "0" "0" "0" --job-zoom="0" --max-zoom="$((JOB_ZOOM-1))" > $jobs_file
    python generate_jobs.py pyramid "$TILE_X" "$TILE_Y" "$TILE_Z" --job-zoom="$JOB_ZOOM" >> $jobs_file
    pipecat publish --amqpuri="$AMQP_URI" "$jobs_queue" < $jobs_file
}

generate_world_jobs

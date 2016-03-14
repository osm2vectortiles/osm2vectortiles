#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly OSM_HOST=$DB_PORT_5432_TCP_ADDR
readonly OSM_PORT=$DB_PORT_5432_TCP_PORT
readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}
readonly EXPORT_DIR=${EXPORT_DIR:-"./"}

function export_list() {
    local list_file="$EXPORT_DIR/tiles.txt"
	local sql_command="SELECT z || '/' || x || '/' || y
                       FROM changed_tiles_latest_timestamp()"

	pgclimb \
        -c "$sql_command" \
        -o "$list_file" \
        -dbname "$OSM_DB" \
        --username "$OSM_USER" \
        --host "$OSM_HOST" \
        --port "$OSM_PORT" \
        --pass "$OSM_PASSWORD" \
    tsv
}

export_list

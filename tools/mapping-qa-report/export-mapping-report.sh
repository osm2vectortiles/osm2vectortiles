#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly DB_HOST=$DB_PORT_5432_TCP_ADDR
readonly DB_PORT=$DB_PORT_5432_TCP_PORT
readonly OSM_NAME=${OSM_NAME:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

readonly EXPORT_DIR=${EXPORT_DIR:-"/data/"}

function exec_sql_file() {
	local sql_file=$1
	PG_PASSWORD=$OSM_PASSWORD psql \
        --host="$DB_HOST" \
        --port=5432 \
        --dbname="$OSM_NAME" \
        --username="$OSM_USER" \
        -v ON_ERROR_STOP=1 \
        -a -f "$sql_file"
}

function export_tsv() {
    local tsv_filename="$1"
    local tsv_file="$EXPORT_DIR/$tsv_filename"
    local sql_file="$2"

    pgclimb \
        -f "$sql_file" \
        -o "$tsv_file" \
        -dbname "$OSM_NAME" \
        --username "$OSM_USER" \
        --host "$DB_HOST" \
        --port "$DB_PORT" \
        --pass "$OSM_PASSWORD" \
    tsv --header
}

function export_report() {
    exec_sql_file "functions.sql"
    export_tsv "mapping_report.tsv" "report.sql"
}

export_report

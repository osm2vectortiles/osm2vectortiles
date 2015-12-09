#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly DB_HOST=$DB_PORT_5432_TCP_ADDR
readonly DB_PORT=$DB_PORT_5432_TCP_PORT

readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

function exec_psql() {
    PG_PASSWORD=$OSM_PASSWORD psql --host="$DB_HOST" --port=5432 --dbname="$OSM_DB" --username="$OSM_USER"
}

function exec_sql_file() {
	local sql_file=$1
    cat "$sql_file" | exec_psql
}

function drop_table() {
    local table=$1
	local drop_command="DROP TABLE IF EXISTS $table;"
	echo $drop_command | exec_psql
}

function hide_inserts() {
    grep -v "INSERT 0 1"
}

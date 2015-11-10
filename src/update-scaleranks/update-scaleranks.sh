#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly SQL_FILE=${IMPORT_DATA_DIR:-/usr/src/app/update.sql}

readonly DB_HOST=$DB_PORT_5432_TCP_ADDR
readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

function exec_sql_file() {
	local sql_file=$1
	PG_PASSWORD=$OSM_PASSWORD psql --host="$DB_HOST" --port=5432 --dbname="$OSM_DB" --username="$OSM_USER" -a -f "$sql_file"
}

function main() {
    echo "Updating scalerank in $OSM_DB"
    exec_sql_file "$SQL_FILE"
}

main

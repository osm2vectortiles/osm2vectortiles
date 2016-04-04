#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly SQL_FUNCTIONS_FILE=${IMPORT_DATA_DIR:-/usr/src/app/functions.sql}
readonly SQL_VIEWS_DIR=${IMPORT_DATA_DIR:-/usr/src/app/views/}

readonly DB_HOST=$DB_PORT_5432_TCP_ADDR
readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

function exec_sql_file() {
	local sql_file=$1
	PG_PASSWORD=$OSM_PASSWORD psql \
        --host="$DB_HOST" \
        --port=5432 \
        --dbname="$OSM_DB" \
        --username="$OSM_USER" \
        -v ON_ERROR_STOP=1 \
        -a -f "$sql_file"
}

function main() {
    echo "Creating triggers in $OSM_DB"
    exec_sql_file "$SQL_TRIGGERS_FILE"
    echo "Creating functions in $OSM_DB"
    exec_sql_file "$SQL_FUNCTIONS_FILE"
    echo "Creating views in $OSM_DB"
    exec_sql_file "${SQL_VIEWS_DIR}admin.sql"
    exec_sql_file "${SQL_VIEWS_DIR}aeroway.sql"
    exec_sql_file "${SQL_VIEWS_DIR}barrier_line.sql"
    exec_sql_file "${SQL_VIEWS_DIR}building.sql"
    exec_sql_file "${SQL_VIEWS_DIR}housenum_label.sql"
    exec_sql_file "${SQL_VIEWS_DIR}landuse.sql"
    exec_sql_file "${SQL_VIEWS_DIR}landuse_overlay.sql"
    exec_sql_file "${SQL_VIEWS_DIR}place_label.sql"
    exec_sql_file "${SQL_VIEWS_DIR}poi_label.sql"
    exec_sql_file "${SQL_VIEWS_DIR}road.sql"
    exec_sql_file "${SQL_VIEWS_DIR}road_label.sql"
    exec_sql_file "${SQL_VIEWS_DIR}bridge.sql"
    exec_sql_file "${SQL_VIEWS_DIR}tunnel.sql"
    exec_sql_file "${SQL_VIEWS_DIR}water.sql"
    exec_sql_file "${SQL_VIEWS_DIR}water_label.sql"
    exec_sql_file "${SQL_VIEWS_DIR}waterway.sql"
    exec_sql_file "${SQL_VIEWS_DIR}waterway_label.sql"
    exec_sql_file "${SQL_VIEWS_DIR}mountain_peak_label.sql"
    exec_sql_file "${SQL_VIEWS_DIR}airport_label.sql"
    exec_sql_file "${SQL_VIEWS_DIR}rail_station_label.sql"
}

main

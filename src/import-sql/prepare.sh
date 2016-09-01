#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly SQL_CREATE_INDIZES=${SQL_CREATE_INDIZES:-false}

function exec_sql_file() {
    local file_name="$1"
    PGPASSWORD=$POSTGRES_ENV_POSTGRES_PASSWORD psql \
        -v ON_ERROR_STOP=1 \
        --host="$POSTGRES_PORT_5432_TCP_ADDR" \
        --port="5432" \
        --dbname="$POSTGRES_ENV_POSTGRES_DB" \
        --username="$POSTGRES_ENV_POSTGRES_USER" \
        -f "$file_name"
}

function main() {
    echo "Create vector tile utility functions"
    exec_sql_file "$VT_UTIL_FILE"
    echo "Creating functions"
    exec_sql_file "$SQL_FUNCTIONS_FILE"
    echo "Creating generated functions"
    exec_sql_file "$SQL_GENERATED_FILE"
    echo "Creating layers in $OSM_DB"
    exec_sql_file "${SQL_LAYERS_DIR}admin.sql"
    exec_sql_file "${SQL_LAYERS_DIR}aeroway.sql"
    exec_sql_file "${SQL_LAYERS_DIR}barrier_line.sql"
    exec_sql_file "${SQL_LAYERS_DIR}building.sql"
    exec_sql_file "${SQL_LAYERS_DIR}housenum_label.sql"
    exec_sql_file "${SQL_LAYERS_DIR}landuse.sql"
    exec_sql_file "${SQL_LAYERS_DIR}landuse_overlay.sql"
    exec_sql_file "${SQL_LAYERS_DIR}place_label.sql"
    exec_sql_file "${SQL_LAYERS_DIR}poi_label.sql"
    exec_sql_file "${SQL_LAYERS_DIR}road.sql"
    exec_sql_file "${SQL_LAYERS_DIR}road_label.sql"
    exec_sql_file "${SQL_LAYERS_DIR}water.sql"
    exec_sql_file "${SQL_LAYERS_DIR}water_label.sql"
    exec_sql_file "${SQL_LAYERS_DIR}waterway.sql"
    exec_sql_file "${SQL_LAYERS_DIR}waterway_label.sql"
    exec_sql_file "${SQL_LAYERS_DIR}mountain_peak_label.sql"
    exec_sql_file "${SQL_LAYERS_DIR}airport_label.sql"
    exec_sql_file "${SQL_LAYERS_DIR}rail_station_label.sql"
    exec_sql_file "${SQL_LAYERS_DIR}motorway_junction.sql"

    if [ "$SQL_CREATE_INDIZES" = true ] ; then
        echo "Create index in $OSM_DB"
        exec_sql_file "${SQL_INDIZES_FILE}"
    else
        echo "Omitting index creation in $OSM_DB"
    fi
}

main

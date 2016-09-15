#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly SQL_FUNCTIONS_FILE=${IMPORT_DATA_DIR:-/usr/src/app/functions.sql}
readonly SQL_LAYERS_DIR=${IMPORT_DATA_DIR:-/usr/src/app/layers/}
readonly SQL_CREATE_INDIZES=${SQL_CREATE_INDIZES:-false}
readonly SQL_SPLIT_POLYGON_FILE=${SQL_SPLIT_POLYGON_FILE:-/usr/src/app/landuse_split_polygon_table.sql}
readonly SQL_SUBDIVIDE_POLYGON_FILE=${SQL_SUBDIVIDE_POLYGON_FILE:-/usr/src/app/subdivide_polygons.sql}

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
    echo "Creating functions in $OSM_DB"
    exec_sql_file "$SQL_XYZ_EXTENT_FILE"
    exec_sql_file "$SQL_FUNCTIONS_FILE"
    echo "Creating generated functions in $OSM_DB"
    exec_sql_file "$SQL_GENERATED_FILE"
    echo "Creating triggers in $OSM_DB"
    exec_sql_file "$SQL_TRIGGERS_FILE"
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

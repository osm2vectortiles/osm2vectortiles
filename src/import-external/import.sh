#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly DB_HOST=$DB_PORT_5432_TCP_ADDR
readonly DB_PORT=$DB_PORT_5432_TCP_PORT
readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

readonly IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
readonly WATER_POLYGONS_FILE="$IMPORT_DATA_DIR/water_polygons.shp"
readonly NATURAL_EARTH_SQLITE_FILE="$IMPORT_DATA_DIR/natural_earth_vector.sqlite"

function run_psql() {
    PSQL_COMMAND= PG_PASSWORD=$OSM_PASSWORD psql --host="$DB_HOST" --port=5432 --dbname="$OSM_DB" --username="$OSM_USER"
}

function exec_sql_file() {
	local sql_file=$1
    cat "$sql_file" | run_psql
}

function import_shp() {
	local shp_file=$1
	shp2pgsql -g way "$shp_file" | run_psql | grep -v "INSERT 0 1"
}

function create_index() {
    local table=$1
    local index_name="$table"_index
	local index_command="CREATE INDEX $index_name ON $table USING gist (way) WITH (FILLFACTOR=100);"
	echo $index_command | run_psql
}

function drop_table() {
    local table=$1
	local drop_command="DROP TABLE IF EXISTS $table;"
	echo $drop_command | run_psql
}

function import_sqlite() {
    echo "Importing Natural Earth to PostGIS..."
    PGCLIENTENCODING=UTF8 ogr2ogr \
    -progress \
    -f Postgresql \
    -s_srs EPSG:4326 \
    -t_srs EPSG:3857 \
    -clipsrc -180.1 -85.0511 180.1 85.0511 \
    PG:"dbname=$OSM_DB user=$OSM_USER host=$DB_HOST port=$DB_PORT" \
    -lco GEOMETRY_NAME=geom \
    -lco DIM=2 \
    -nlt GEOMETRY \
    -overwrite \
    "$NATURAL_EARTH_SQLITE_FILE"
}

function import_water() {
    local water_table="water_polygons"
    echo "Removing existing table $water_table"
    drop_table $water_table

    echo "Importing $WATER_POLYGONS_FILE into table $water_table"
    import_shp "$WATER_POLYGONS_FILE"

    echo "Create index on table $water_table"
    create_index $water_table
}

function hide_inserts() {
    grep -v "INSERT 0 1"
}

function update_scaleranks() {
    echo "Updating scalerank in $OSM_DB"
    exec_sql_file "update.sql"
    echo "Inserting labels in $OSM_DB"
    exec_sql_file "marine.sql" | hide_inserts
    exec_sql_file "states.sql" | hide_inserts
    exec_sql_file "countries.sql" | hide_inserts
}

function main() {
    update_scaleranks
    import_water
    import_sqlite
}

main

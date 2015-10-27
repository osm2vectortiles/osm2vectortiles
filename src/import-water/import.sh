#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
readonly WATER_SHP_DOWNLOAD_URL=${WATER_SHP_DOWNLOAD_URL:-false}

readonly DB_HOST=$DB_PORT_5432_TCP_ADDR
readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

function import_shp() {
	local shp_file=$1
	shp2pgsql -g way "$shp_file" | PG_PASSWORD=$OSM_PASSWORD psql --host="$DB_HOST" --port=5432 --dbname="$OSM_DB" --username="$OSM_USER" | grep -v "INSERT 0 1"
}

function create_index() {
    local table=$1
    local index_name="$table"_index
	local index_command="CREATE INDEX $index_name ON $table USING gist (way) WITH (FILLFACTOR=100);"
	echo $index_command | PG_PASSWORD=$OSM_PASSWORD psql --host="$DB_HOST" --port=5432 --dbname="$OSM_DB" --username="$OSM_USER"
}

function drop_table() {
    local table=$1
	local drop_command="DROP TABLE IF EXISTS $table;"
	echo $drop_command | PG_PASSWORD=$OSM_PASSWORD psql --host="$DB_HOST" --port=5432 --dbname="$OSM_DB" --username="$OSM_USER"
}

function main() {
    local water_polygons="$IMPORT_DATA_DIR/water_polygons.shp"
    local land_polygons="$IMPORT_DATA_DIR/land_polygons.shp"

    local water_table="water_polygons"
    echo "Removing existing table $water_table"
    drop_table $water_table

    echo "Importing $water_polygons into table $water_table"
    import_shp $water_polygons

    echo "Create index on table $water_table"
    create_index $water_table

    local land_table="land_polygons"
    echo "Removing existing table $land_polygons"
    drop_table $land_table

    echo "Importing $land_polygons into table $land_table"
    import_shp $land_polygons

    echo "Create index on table $land_table"
    create_index $land_table
}

main

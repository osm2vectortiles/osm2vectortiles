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
	local index_command="CREATE INDEX water_polygons_index ON water_polygons USING gist (way) WITH (FILLFACTOR=100);"
	echo $index_command | PG_PASSWORD=$OSM_PASSWORD psql --host="$DB_HOST" --port=5432 --dbname="$OSM_DB" --username="$OSM_USER"
}

function drop_water() {
	local drop_command="DROP TABLE IF EXISTS water_polygons;"
	echo $drop_command | PG_PASSWORD=$OSM_PASSWORD psql --host="$DB_HOST" --port=5432 --dbname="$OSM_DB" --username="$OSM_USER"
}

function main() {
    local shp_file
    local _shp_file
    for _shp_file in "$IMPORT_DATA_DIR"/*.shp; do
        shp_file=$_shp_file
        break
    done
    echo "Found shp file $shp_file"

    local table_name="water_polygons"
    echo "Removing existing table $table_name"
    drop_water

    echo "Importing $shp_file into table $table_name"
    import_shp $shp_file

    echo "Create index water_polygons_index on table $table_name"
    create_index
}

main

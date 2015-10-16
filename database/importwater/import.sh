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

function download_shp() {
	local pbf_url=$1
	wget --directory-prefix "$IMPORT_DATA_DIR" --no-clobber "$pbf_url"
	cd $IMPORT_DATA_DIR
	unzip water-polygons-split-3857.zip
	rm water-polygons-split-3857.zip
}

function import_shp() {
	local shp_file=$1
	shp2pgsql -g way $shp_file | PG_PASSWORD=$OSM_PASSWORD psql --host="$DB_HOST" --port=5432 --dbname="$OSM_DB" --username="$OSM_USER"
}

function main() {
    if ! [ $WATER_SHP_DOWNLOAD_URL = false ]; then
    	download_shp $WATER_SHP_DOWNLOAD_URL
    fi

    local shp_file
    local _shp_file
    for _shp_file in "$IMPORT_DATA_DIR"/*.shp; do
	shp_file=$_shp_file
	break
    done

    echo "Found shp file $shp_file"

    import_shp $shp_file
}

main

#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

readonly DB_HOST=$DB_PORT_5432_TCP_ADDR
readonly DATADIR=/data/import

function download_shp() {
	mkdir $DATADIR
	cd $DATADIR
	wget $WATER_SHP_DOWNLOAD_URL
	unzip water-polygons-split-3857.zip
	rm water-polygons-split-3857.zip
}

function import_shp() {
	cd $DATADIR
	shp2pgsql -g way water-polygons-split-3857/water_polygons.shp | psql -h $DB_HOST -p 5432 -U $OSM_USER -W $OSM_PASSWORD -d $OSM_DB
}

function main() {
	#download_shp
    import_shp
}

main
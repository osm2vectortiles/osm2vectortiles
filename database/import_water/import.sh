#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

readonly DB_HOST=$DB_PORT_5432_TCP_ADDR

function import_shp() {
	shp2pgsql -g way /data/water-polygons-split-3857/water_polygons.shp | psql -h $DB_HOST -p 5432 -U $OSM_USER -W $OSM_PASSWORD $OSM_DB
}

function main() {
    import_shp
}

main
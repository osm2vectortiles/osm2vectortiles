#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
readonly WATER_POLYGONS_FILE="$IMPORT_DATA_DIR/water_polygons.shp"
readonly SIMPLIFIED_WATER_POLYGONS_FILE="$IMPORT_DATA_DIR/simplified_water_polygons.shp"

source sql.sh

function import_shp() {
	local shp_file=$1
	local table_name=$2
	shp2pgsql -s 3857 -I -g geometry "$shp_file" "$table_name" | exec_psql | hide_inserts
}

function generalize_water() {
    echo 'CREATE TABLE osm_ocean_polygon_gen0 AS SELECT ST_Simplify(geometry, 30000) AS geometry FROM osm_ocean_polygon_gen1' | exec_psql
    echo 'CREATE INDEX ON osm_ocean_polygon_gen0 USING gist (geometry)' | exec_psql
    echo 'ANALYZE osm_ocean_polygon_gen0' | exec_psql
}

function import_water() {
    local table_name="osm_ocean_polygon"
    local simplified_table_name="osm_ocean_polygon_gen1"

    drop_table "$table_name"
    import_shp "$WATER_POLYGONS_FILE" "$table_name"

    drop_table "$simplified_table_name"
    import_shp "$SIMPLIFIED_WATER_POLYGONS_FILE" "$simplified_table_name"

    generalize_water
}

import_water

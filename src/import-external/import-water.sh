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
	shp2pgsql -I -g way "$shp_file" "$table_name" | exec_psql | hide_inserts
}

function import_water() {
    local table_name="osm_ocean_polygons"
    local simplified_table_name="osm_ocean_polygons_gen0"

    drop_table "$table_name"
    import_shp "$WATER_POLYGONS_FILE" "$table_name"

    drop_table "$simplified_table_name"
    import_shp "$SIMPLIFIED_WATER_POLYGONS_FILE" "$simplified_table_name"
}

import_water

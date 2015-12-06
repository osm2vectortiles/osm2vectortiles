#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
readonly WATER_POLYGONS_FILE="$IMPORT_DATA_DIR/water_polygons.shp"

source sql.sh

function import_shp() {
	local shp_file=$1
	shp2pgsql -g way "$shp_file" | exec_psql | hide_inserts
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

import_water

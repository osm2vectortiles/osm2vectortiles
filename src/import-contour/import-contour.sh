#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
readonly IMPORT_CONTOUR_DIR="${IMPORT_DATA_DIR}/contour"

source sql.sh

function import_shp() {
	local shp_file=$1
	local table_name=$2
	local a_parameter=${3:-''}
	# for WGS84 use 4326:3857
	# for EPSG:3857 use 3857:3857
	shp2pgsql  $a_parameter -s 3857:3857 -I -g geometry "$shp_file" "$table_name" | exec_psql | hide_inserts
}

function generalize_contour() {
    local table=$1
	local gen_table=$2
	local tolerance=$3

	local drop_command="DROP TABLE IF EXISTS $gen_table CASCADE;"
	echo $drop_command | exec_psql

	local gen_command="CREATE TABLE $gen_table AS SELECT id, height, ST_SimplifyPreserveTopology(geometry,$tolerance) as geometry from $table;"
	echo $gen_command | exec_psql
}

function import_contour() {

    local table_name="contour_lines"
	local table_name_gen0=${table_name}_gen0
	local table_name_gen1=${table_name}_gen1
    drop_table_cascade "$table_name_gen0"
    drop_table_cascade "$table_name_gen1"

	local a_parameter=''

	if [ "$(ls -A $IMPORT_CONTOUR_DIR/*.zip 2> /dev/null)" ]; then
        local zip_file
		local file_basename
        for zip_file in "$IMPORT_CONTOUR_DIR"/*.zip; do
			file_basename=`basename $zip_file .zip`
			echo ""
            echo "Importing $zip_file: "
			
			# unzipping into same import folder, probably it's better to use temp folder instead
			unzip -q -o $zip_file -d $IMPORT_CONTOUR_DIR
			import_shp "$IMPORT_CONTOUR_DIR/$file_basename/$file_basename.shp" $table_name $a_parameter
			rm -r "$IMPORT_CONTOUR_DIR/$file_basename/"
			
			# this parameter means adding shapefile into existing table, set for every next file
			a_parameter='-a'
        done
    else
        echo "No ZIP files found in contour folder."
        echo "Please mount the $IMPORT_CONTOUR_DIR volume to a folder containing ZIP files with contour shapefiles."
        exit 404
    fi

	# for zoom 11 and lower
	generalize_contour $table_name $table_name_gen0 30.0

	# for zooms 13 and 12
	generalize_contour $table_name $table_name_gen1 10.0


}


import_contour




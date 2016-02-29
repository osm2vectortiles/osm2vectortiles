#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly WORLD_MBTILES=${WORLD_MBTILES:-"world.mbtiles"}
readonly EXTRACT_DIR=$(dirname $WORLD_MBTILES)
readonly MIN_ZOOM=${MIN_ZOOM:-0}
readonly MAX_ZOOM=${MAX_ZOOM:-14}
readonly GLOBAL_BBOX="-180, -85.0511, 180, 85.0511"

function create_extract() {
    local extract_file="$EXTRACT_DIR/$1"
    local bounds="$2"

    echo "Create extract $extract_file"
    tilelive-copy \
        --minzoom="$MIN_ZOOM" \
        --maxzoom="$MAX_ZOOM" \
        --bounds="$bounds" \
        "$WORLD_MBTILES" "$extract_file"

    echo "Update metadata $extract_file"
    update_metadata "$extract_file" "$bounds"
}

function update_metadata_entry() {
    local extract_file="$1"
    local name="$2"
    local value="$3"
    local stmt="UPDATE metadata SET VALUE='$value' WHERE name = '$name';"
    sqlite3 "$extract_file" "$stmt"
}

function insert_metadata_entry() {
    local extract_file="$1"
    local name="$2"
    local value="$3"
    local stmt="INSERT OR IGNORE INTO metadata VALUES('$name','$value');"
    sqlite3 "$extract_file" "$stmt"
}

function update_metadata() {
    local extract_file="$1"
    local extract_bounds="$2"
    local attribution="&copy; OpenStreetMap contributors"

    insert_metadata_entry "$extract_file" "attribution" "$attribution"
    update_metadata_entry "$extract_file" "name" "Open Streets v1.0"
    update_metadata_entry "$extract_file" "description" "Open Streets v1.0"
    update_metadata_entry "$extract_file" "bounds" "$extract_bounds"
}

function create_country_extracts() {
	create_extract "afghanistan.mbtiles" "60.403889,29.288333,74.989862,38.5899217"
	create_extract "albania.mbtiles" "19.0246095,39.5448625,21.1574335,42.7611669"
	create_extract "algeria.mbtiles" "-8.7689089,18.868147,12.097337,37.3962055"
	create_extract "andorra.mbtiles" "1.3135781,42.3288238,1.8863837,42.7559357"
	create_extract "angola.mbtiles" "11.3609793,-18.1389449,24.18212,-4.2888889"
}

function main() {
	if [ ! -f "$WORLD_MBTILES" ]; then
		echo "$WORLD_MBTILES not found."
		exit 403
	fi
    create_country_extracts
}

main

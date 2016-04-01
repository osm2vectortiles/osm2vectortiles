#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
readonly OSM_UPDATE_BASEURL=${OSM_UPDATE_BASEURL:-false}

function osm_update_pbf() {
    local pbf_file="$1"
    local latest_diffs_file="$IMPORT_DATA_DIR/latest.osc.gz"
    if [ "$OSM_UPDATE_BASEURL" = false ]; then
        osmupdate "$pbf_file" "$latest_diffs_file"
    else
        echo "Downloading diffs from $OSM_UPDATE_BASEURL"
        osmupdate -v \
            "$pbf_file" "$latest_diffs_file" \
            --base-url="$OSM_UPDATE_BASEURL"
    fi
}

function main() {
	cd $IMPORT_DATA_DIR
    if [ "$(ls -A $IMPORT_DATA_DIR/*.pbf 2> /dev/null)" ]; then
        local pbf_file
        for pbf_file in "$IMPORT_DATA_DIR"/*.pbf; do
            osm_update_pbf "$pbf_file"
        done
    else
        echo "No PBF files for downloading changes."
        echo "Please mount the $IMPORT_DATA_DIR volume to a folder containing the latest imported OSM PBF file."
        exit 404
    fi
}

main

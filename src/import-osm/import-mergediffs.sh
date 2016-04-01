#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
readonly DIFFS_FILE="$IMPORT_DATA_DIR/latest.osc.gz"

function merge_latest_diffs() {
    local pbf_file="$1"
    local latest_diffs_file="$2"
    local latest_pbf_file="$IMPORT_DATA_DIR/${pbf_file##*/}.latest.pbf"

    echo "Updating $pbf_file with changes $latest_diffs_file"
    osmconvert -v "$pbf_file" "$latest_diffs_file" -o="$latest_pbf_file"
    rm "$pbf_file"
    mv "$latest_pbf_file" "$pbf_file"
}

function main() {
    if [ "$(ls -A $IMPORT_DATA_DIR/*.pbf 2> /dev/null)" ]; then
        local pbf_file
        for pbf_file in "$IMPORT_DATA_DIR"/*.pbf; do
            merge_latest_diffs "$pbf_file" "$DIFFS_FILE"
        done
    else
        echo "No PBF files for downloading changes."
        echo "Please mount the $IMPORT_DATA_DIR volume to a folder containing the latest imported OSM PBF file."
        exit 404
    fi
}

main

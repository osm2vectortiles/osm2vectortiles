#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

source import.sh
readonly TILELIST=${TILELIST:-/data/export/tiles.txt}

function main() {
    if [ "$(ls -A $IMPORT_DATA_DIR/*.osc.gz 2> /dev/null)" ]; then
        local diff_file
        for diff_file in "$IMPORT_DATA_DIR"/*.osc.gz; do
            import_pbf_diffs "$diff_file" "$TILELIST"
            break
        done
    else
        echo "No PBF files for importing diffs."
        echo "Please mount the $IMPORT_DATA_DIR volume to a folder containing the latest imported OSM PBF file."
        exit 404
    fi
}

main

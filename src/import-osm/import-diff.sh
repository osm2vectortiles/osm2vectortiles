#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

source import.sh

function main() {
    if [ "$(ls -A $IMPORT_DATA_DIR/*.pbf 2> /dev/null)" ]; then
        local pbf_file
        for pbf_file in "$IMPORT_DATA_DIR"/*.pbf; do
            import_pbf_diffs "$pbf_file"
            break
        done
    else
        echo "No PBF files for importing diffs."
        echo "Please mount the $IMPORT_DATA_DIR volume to a folder containing the latest imported OSM PBF file."
        exit 404
    fi
}

main

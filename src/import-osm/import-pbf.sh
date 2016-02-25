#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly PBF_DOWNLOAD_URL=${PBF_DOWNLOAD_URL:-false}

source import.sh

function main() {
    if ! [ "$PBF_DOWNLOAD_URL" = false ]; then
        download_pbf "$PBF_DOWNLOAD_URL"
    fi

    if [ "$(ls -A $IMPORT_DATA_DIR/*.pbf 2> /dev/null)" ]; then
        local pbf_file
        for pbf_file in "$IMPORT_DATA_DIR"/*.pbf; do
            drop_views
            import_pbf "$pbf_file"
            break
        done
    else
        echo "No PBF files for import found."
        echo "Please mount the $IMPORT_DATA_DIR volume to a folder containing OSM PBF files."
        exit 404
    fi
}

main

#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly PBF_DOWNLOAD_URL=${PBF_DOWNLOAD_URL:-false}

source import.sh

function main() {
    if ! [ $PBF_DOWNLOAD_URL = false ]; then
        download_pbf $PBF_DOWNLOAD_URL
    fi

    import_single_pbf
}

main

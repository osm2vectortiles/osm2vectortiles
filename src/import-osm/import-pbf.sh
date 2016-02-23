#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly PBF_DOWNLOAD_URL=${PBF_DOWNLOAD_URL:-false}

source import.sh

function read_pbf_timestamp() {
    local timestamp=$(cat $IMPORT_DATA_DIR/state.txt | grep 'timestamp=')
    local nothing=''
    local pruned_timestamp="${timestamp/timestamp=/$nothing}"
    echo $pruned_timestamp | sed -r 's/\\+//g'
}

function main() {
    if ! [ $PBF_DOWNLOAD_URL = false ]; then
        download_pbf $PBF_DOWNLOAD_URL
    fi

    import_single_pbf
	add_timestamp_column

    if [ -f $IMPORT_DATA_DIR/state.txt ]; then
        local timestamp=$(read_pbf_timestamp)
        update_timestamp "$timestamp"
    fi
}

main

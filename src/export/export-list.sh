#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

source utils.sh

readonly LIST_FILE="$EXPORT_DIR/tiles.txt"

function export_local_mbtiles() {
    local mbtiles_name="tiles.mbtiles"

    if [ ! -f "$LIST_FILE" ]; then
       echo "List file "$LIST_FILE" does not exist"
       exit 500
    fi

    exec tilelive-copy \
        --scheme="list" \
        --list="$LIST_FILE" \
        "tmsource://$DEST_PROJECT_DIR" "mbtiles://$EXPORT_DIR/$mbtiles_name"
}

function main() {
    copy_source_project
    cleanup_dest_project
    replace_db_connection
    export_local_mbtiles
}

main

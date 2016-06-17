#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly CITIES_TSV=${CITIES_TSV:-"city_extracts.tsv"}
readonly COUNTRIES_TSV=${COUNTRIES_TSV:-"country_extracts.tsv"}
readonly WORLD_MBTILES=${WORLD_MBTILES:-"world.mbtiles"}
readonly EXTRACT_DIR=$(dirname "$WORLD_MBTILES")
readonly PATCH_SRC="$EXTRACT_DIR/world_z0-z5.mbtiles"

function main() {
    if [ ! -f "$WORLD_MBTILES" ]; then
        echo "$WORLD_MBTILES not found."
        exit 10
    fi

    local upload_flag='--upload'
    if [ -z "${S3_ACCESS_KEY}" ]; then
        upload_flag=''
        echo 'Skip upload since no S3_ACCESS_KEY was found.'
    fi

    # Generate patch sources first but do not upload them
    python -u create_extracts.py zoom-level "$WORLD_MBTILES" \
        --max-zoom=5 --target-dir="$EXTRACT_DIR"
    python -u create_extracts.py zoom-level "$WORLD_MBTILES" \
        --max-zoom=8 --target-dir="$EXTRACT_DIR"

    python -u create_extracts.py bbox "$WORLD_MBTILES" "$CITIES_TSV" \
        --patch-from="$PATCH_SRC" --target-dir="$EXTRACT_DIR" $upload_flag
    python -u create_extracts.py bbox "$WORLD_MBTILES" "$COUNTRIES_TSV" \
        --patch-from="$PATCH_SRC" --target-dir="$EXTRACT_DIR" $upload_flag
}

main

#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly WORLD_MBTILES=${WORLD_MBTILES:-"world.mbtiles"}
readonly PATCH_MBTILES=${PATCH_MBTILES:-"world_z0-z5.mbtiles"}
readonly CITIES_TSV=${CITIES_TSV:-"city_extracts.tsv"}
readonly COUNTRIES_TSV=${COUNTRIES_TSV:-"country_extracts.tsv"}
readonly EXTRACT_DIR=$(dirname "$WORLD_MBTILES")
readonly VERSION=${VERSION:-1}
readonly GLOBAL_BBOX="-180, -85.0511, 180, 85.0511"
readonly S3_CONFIG_FILE=${S3_CONFIG_FILE:-"$HOME/.s3cfg"}
readonly S3_BUCKET_NAME=${S3_BUCKET_NAME:-"osm2vectortiles-downloads"}
readonly S3_PREFIX=${S3_PREFIX:-"v1.0/extracts/"}

function upload_extract() {
    local mbtiles_extract="$1"
    s3cmd --config="$S3_CONFIG_FILE" \
          --access_key="$S3_ACCESS_KEY" \
          --secret_key="$S3_SECRET_KEY" \
        put "$mbtiles_extract" "s3://$S3_BUCKET_NAME/$S3_PREFIX" \
          --acl-public \
          --multipart-chunk-size-mb=50
}

function create_lower_zoomlevel_extract() {
    local extract_file="$EXTRACT_DIR/$1"
    local min_zoom="$2"
    local max_zoom="$3"

    local center_zoom="1"
    local center_longitude="-94.1629"
    local center_latitude="34.5133"
    local center="$center_longitude,$center_latitude,$center_zoom"

    echo "Create extract $extract_file"
    tilelive-copy \
        --minzoom="$min_zoom" \
        --maxzoom="$max_zoom" \
        --bounds="$GLOBAL_BBOX" \
        "$WORLD_MBTILES" "$extract_file"

    echo "Update metadata $extract_file"
    update_metadata "$extract_file" "$GLOBAL_BBOX" "$center" "$min_zoom" "$max_zoom"

    echo "Uploading $extract_file"
    upload_extract "$extract_file"
}

function main() {
    if [ ! -f "$WORLD_MBTILES" ]; then
        echo "$WORLD_MBTILES not found."
        exit 10
    fi

    if [ -z "${S3_ACCESS_KEY}" ]; then
        echo 'Skip upload since no S3_ACCESS_KEY was found.'
    fi

    python create_extracts.py "$WORLD_MBTILES" "$CITIES_TSV" --target-dir="$EXTRACT_DIR"
    python create_extracts.py "$WORLD_MBTILES" "$COUNTRIES_TSV" --target-dir="$EXTRACT_DIR"
}

main

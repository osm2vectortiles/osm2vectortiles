#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

SOURCE_DATA_DIR=${SOURCE_DATA_DIR:-/data}
DEST_DATA_DIR=${DEST_DATA_DIR:-/project}
PORT=${PORT:-80}
CACHE_SIZE=${CACHE_SIZE:-10}
SOURCE_CACHE_SIZE=${SOURCE_CACHE_SIZE:-10}

# find first tm2 project
if [ "$(ls -A $SOURCE_DATA_DIR)" ]; then
    if [ -d "$SOURCE_DATA_DIR"/*.tm2 ]; then
        for _PROJECT_DIR in "$SOURCE_DATA_DIR"/*.tm2; do
            [ -d "${_PROJECT_DIR}" ] && PROJECT_DIR="${_PROJECT_DIR}" && break
        done
    else
        MBTILES_FILE=""
        for _MBTILES_FILE in "$SOURCE_DATA_DIR"/*.mbtiles; do
            MBTILES_FILE="${_MBTILES_FILE}"
            break
        done

        if [ -f "$MBTILES_FILE" ]; then
            echo "The mbtiles file is now served with X-Ray styles"

            exec tessera "xray+mbtiles://$MBTILES_FILE" \
                --PORT $PORT \
                --cache-size $CACHE_SIZE \
                --source-cache-size $SOURCE_CACHE_SIZE
        else
            echo "No tm2 projects found. Please add a tm2 project to your mounted folder."
            exit 404
        fi
    fi
else
    echo "No tm2 projects found. Please mount the $SOURCE_DATA_DIR volume to a folder containing tm2 projects."
    exit 404
fi

# find all tm2 projects but only the first project will be hosted for now
PROJECT_NAME="${PROJECT_DIR##*/}"
PROJECT_CONFIG_FILE="${PROJECT_DIR%%/}/project.yml"
VECTORTILES_NAME="${PROJECT_NAME%.tm2}.mbtiles"
MBTILES_FILE="${SOURCE_DATA_DIR%%/}/$VECTORTILES_NAME"

echo "Found project ${PROJECT_NAME}"

# project config will be copied to new folder because we
# modify the source configuration of the style and don't want
# that to effect the original file
DEST_PROJECT_DIR="${DEST_DATA_DIR%%/}/$PROJECT_NAME"
DEST_PROJECT_CONFIG_FILE="${DEST_PROJECT_DIR%%/}/project.yml"
cp -rf "$PROJECT_DIR" "$DEST_PROJECT_DIR"

# project.yml is single source of truth, therefore the mapnik
# stylesheet is not necessary
rm -f "${DEST_PROJECT_DIR%%/}/project.xml"

# replace external vector tile sources with mbtiles source
# this allows developing rapidyl with an external source and then use the
# mbtiles for dependency free deployment
if [ -f "$MBTILES_FILE" ]; then
    echo "Associating $VECTORTILES_NAME with $PROJECT_NAME"
    replace_expr="s|source: \".*\"|source: \"mbtiles://$MBTILES_FILE\"|g"
    sed -e "$replace_expr" $PROJECT_CONFIG_FILE > $DEST_PROJECT_CONFIG_FILE
else
    echo "No mbtiles matching project $PROJECT_NAME found."
    echo "Please name the mbtiles file the same as your style project."
    exit 500
fi

exec tessera "tmstyle://$DEST_PROJECT_DIR" \
    --PORT $PORT \
    --cache-size $CACHE_SIZE \
    --source-cache-size $SOURCE_CACHE_SIZE

#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

SOURCE_PROJECT_DIR=${SOURCE_PROJECT_DIR:-/data/tm2source}
EXPORT_DIR=${EXPORT_DIR:-/data/export}

OSM_DB=${OSM_DB:-osm}
OSM_USER=${OSM_USER:-osm}
OSM_PASSWORD=${OSM_PASSWORD:-osm}

DB_SCHEMA=public

MIN_ZOOM=${MIN_ZOOM:-0}
MAX_ZOOM=${MAX_ZOOM:-14}
BBOX=${BBOX:--180, -85.0511, 180, 85.0511}

# project config will be copied to new folder because we # modify the source configuration
DEST_PROJECT_DIR="/project"
DEST_PROJECT_FILE="${DEST_PROJECT_DIR%%/}/data.yml"
cp -rf "$SOURCE_PROJECT_DIR" "$DEST_PROJECT_DIR"

# project.yml is single source of truth, therefore the mapnik
# stylesheet is not necessary
rm -f "${DEST_PROJECT_DIR%%/}/project.xml"

# replace database connection with postgis container connection
REPLACE_EXPR_1="s|host: .*|host: $DB_PORT_5432_TCP_ADDR|g"
REPLACE_EXPR_2="s|port: .*|port: $DB_PORT_5432_TCP_PORT|g"
REPLACE_EXPR_3="s|dbname: .*|dbname: $OSM_DB|g"
REPLACE_EXPR_4="s|user: .*|user: $OSM_USER|g"
REPLACE_EXPR_5="s|password: .*|password: $OSM_PASSWORD|g"

sed -i "$REPLACE_EXPR_1" "$DEST_PROJECT_FILE"
sed -i "$REPLACE_EXPR_2" "$DEST_PROJECT_FILE"
sed -i "$REPLACE_EXPR_3" "$DEST_PROJECT_FILE"
sed -i "$REPLACE_EXPR_4" "$DEST_PROJECT_FILE"
sed -i "$REPLACE_EXPR_5" "$DEST_PROJECT_FILE"

exec tl copy -b "$BBOX" --min-zoom $MIN_ZOOM --max-zoom $MAX_ZOOM "tmsource://$DEST_PROJECT_DIR" "mbtiles://$EXPORT_DIR/tiles.mbtiles"

#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
readonly IMPOSM_CACHE_DIR=${IMPOSM_CACHE_DIR:-/data/cache}
readonly MAPPING_JSON=${MAPPING_JSON:-/usr/src/app/mapping.json}

readonly DIFFS=${DIFFS:-true}

readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

readonly DB_SCHEMA=${OSM_SCHEMA:-public}
readonly DB_HOST=$DB_PORT_5432_TCP_ADDR
readonly PG_CONNECT="postgis://$OSM_USER:$OSM_PASSWORD@$DB_HOST/$OSM_DB"

readonly HISTORY_TABLE="osm_timestamps"

function download_pbf() {
    local pbf_url=$1
	wget -q  --directory-prefix "$IMPORT_DATA_DIR" --no-clobber "$pbf_url"
}

function import_pbf() {
    local pbf_file="$1"
    create_timestamp_history
    if [ "$DIFFS" = true ]; then
    echo "Importing in diff mode"
    imposm3 import \
        -connection "$PG_CONNECT" \
        -mapping "$MAPPING_YAML" \
        -overwritecache \
        -cachedir "$IMPOSM_CACHE_DIR" \
        -read "$pbf_file" \
        -dbschema-import="${DB_SCHEMA}" \
        -write -optimize -diff
    else
    echo "Importing in normal mode"
    imposm3 import \
        -connection "$PG_CONNECT" \
        -mapping "$MAPPING_YAML" \
        -overwritecache \
        -cachedir "$IMPOSM_CACHE_DIR" \
        -read "$pbf_file" \
        -dbschema-import="${DB_SCHEMA}" \
        -write -optimize
    fi

    echo "Create osm_water_point table with precalculated centroids"
    create_osm_water_point_table

    echo "Update osm_place_polygon with point geometry"
    update_points

    echo "Subdividing polygons in $OSM_DB"
    subdivide_polygons

    echo "Update scaleranks from Natural Earth data"
    update_scaleranks

    local timestamp=$(extract_timestamp "$pbf_file")
    store_timestamp_history "$timestamp"
}

function extract_timestamp() {
    local file="$1"
    osmconvert "$file" --out-timestamp
}

function update_points() {
    exec_sql_file "point_update.sql"
}

function update_scaleranks() {
    exec_sql_file "update_scaleranks.sql"
}

function create_osm_water_point_table() {
    exec_sql_file "water_point_table.sql"
}

function subdivide_polygons() {
    exec_sql_file "subdivide_polygons.sql"
}

function update_scaleranks() {
    exec_sql_file "update_scaleranks.sql"
}

function create_timestamp_history() {
    exec_sql "DROP TABLE IF EXISTS $HISTORY_TABLE"
    exec_sql "CREATE TABLE $HISTORY_TABLE (timestamp timestamp)"
}

function store_timestamp_history {
    local timestamp="$1"

    exec_sql "DELETE FROM $HISTORY_TABLE WHERE timestamp='$timestamp'::timestamp"
    exec_sql "INSERT INTO $HISTORY_TABLE VALUES ('$timestamp'::timestamp)"
}

function update_timestamp() {
    local timestamp="$1"
    store_timestamp_history "$timestamp"
    exec_sql "SELECT update_timestamp('$timestamp')"
}

function enable_delete_tracking() {
    exec_sql "SELECT enable_delete_tracking()"
}

function drop_osm_delete_indizes() {
    exec_sql "SELECT drop_osm_delete_indizes()"
}

function create_osm_delete_indizes() {
    exec_sql "SELECT create_osm_delete_indizes()"
}

function disable_delete_tracking() {
    exec_sql "SELECT disable_delete_tracking()"
}

function create_delete_tables() {
    exec_sql "SELECT create_delete_tables()"
}

function create_tracking_triggers() {
    exec_sql "SELECT create_tracking_triggers()"
}

function cleanup_osm_changes() {
    exec_sql "SELECT cleanup_osm_tracking_tables()"
}

function exec_sql() {
	local sql_cmd="$1"
	PG_PASSWORD=$OSM_PASSWORD psql \
        --host="$DB_HOST" \
        --port=5432 \
        --dbname="$OSM_DB" \
        --username="$OSM_USER" \
        -c "$sql_cmd"
}

function exec_sql_file() {
    local sql_file=$1
    PG_PASSWORD=$OSM_PASSWORD psql \
        --host="$DB_HOST" \
        --port=5432 \
        --dbname="$OSM_DB" \
        --username="$OSM_USER" \
        -v ON_ERROR_STOP=1 \
        -a -f "$sql_file"
}

function import_pbf_diffs() {
    local pbf_file="$1"
    local diffs_file="$IMPORT_DATA_DIR/latest.osc.gz"

    echo "Create tracking tables"
    create_delete_tables

    echo "Drop indizes for faster inserts"
    drop_osm_delete_indizes

    echo "Enable change tracking for deletes and updates"
    create_tracking_triggers
    enable_delete_tracking

    echo "Import changes from $diffs_file"
    imposm3 diff \
        -connection "$PG_CONNECT" \
        -mapping "$MAPPING_YAML" \
        -cachedir "$IMPOSM_CACHE_DIR" \
        -diffdir "$IMPORT_DATA_DIR" \
        -dbschema-import "${DB_SCHEMA}" \
        "$diffs_file"

    echo "Disable change tracking"
    disable_delete_tracking

    echo "Create osm_water_point table with precalculated centroids"
    create_osm_water_point_table

    echo "Update osm_place_polygon with point geometry"
    update_points

    echo "Subdividing polygons in $OSM_DB"
    subdivide_polygons

    local timestamp=$(extract_timestamp "$diffs_file")
    echo "Set $timestamp for latest updates from $diffs_file"
    update_timestamp "$timestamp"

    echo "Create indizes for faster dirty tile calculation"
    create_osm_delete_indizes

    cleanup_osm_changes
}

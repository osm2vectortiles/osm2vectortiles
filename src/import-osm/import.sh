#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
readonly IMPOSM_CACHE_DIR=${IMPOSM_CACHE_DIR:-/data/cache}
readonly MAPPING_JSON=${MAPPING_JSON:-/usr/src/app/mapping.json}

readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

readonly OSM_UPDATE_BASEURL=${OSM_UPDATE_BASEURL:-false}

readonly DB_SCHEMA=${OSM_SCHEMA:-public}
readonly DB_HOST=$DB_PORT_5432_TCP_ADDR
readonly PG_CONNECT="postgis://$OSM_USER:$OSM_PASSWORD@$DB_HOST/$OSM_DB"

function download_pbf() {
    local pbf_url=$1
	wget -q  --directory-prefix "$IMPORT_DATA_DIR" --no-clobber "$pbf_url"
}

function import_pbf() {
    local pbf_file="$1"
    imposm3 import \
        -connection "$PG_CONNECT" \
        -mapping "$MAPPING_YAML" \
        -overwritecache \
        -cachedir "$IMPOSM_CACHE_DIR" \
        -read "$pbf_file" \
        -dbschema-import="${DB_SCHEMA}" \
        -write -optimize -diff

    local timestamp=$(extract_timestamp "$pbf_file")
    update_timestamp "$timestamp"
}

function extract_timestamp() {
    local file="$1"
    osmconvert "$file" --out-timestamp
}

function store_timestamp_history {
    local timestamp="$1"
    local table_name="osm_timestamps"

    exec_sql "CREATE TABLE IF NOT EXISTS $table_name (timestamp timestamp)"
    exec_sql "DELETE FROM $table_name WHERE timestamp='$timestamp'::timestamp"
    exec_sql "INSERT INTO $table_name VALUES ('$timestamp'::timestamp)"
}

function update_timestamp() {
    local timestamp="$1"
    store_timestamp_history "$timestamp"

	exec_sql "UPDATE osm_admin SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_aero_lines SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_aero_polygons SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_barrier_lines SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_barrier_polygons SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_buildings SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_buildings_gen0 SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_housenumbers_points SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_housenumbers_polygons SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_landusages SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_landusages_gen0 SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_landusages_gen1 SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_places SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_poi_points SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_poi_polygons SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_road_polygon SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_road_linestring SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_water_lines SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_water_polygons SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_water_polygons_gen1 SET timestamp='$timestamp' WHERE timestamp IS NULL"
}

function drop_views() {
    # landuse views
    exec_sql "DROP VIEW IF EXISTS landuse_z5 CASCADE"
    exec_sql "DROP VIEW IF EXISTS landuse_z6 CASCADE"
    exec_sql "DROP VIEW IF EXISTS landuse_z7 CASCADE"
    exec_sql "DROP VIEW IF EXISTS landuse_z8 CASCADE"
    exec_sql "DROP VIEW IF EXISTS landuse_z9 CASCADE"
    exec_sql "DROP VIEW IF EXISTS landuse_z10 CASCADE"
    exec_sql "DROP VIEW IF EXISTS landuse_z11 CASCADE"
    exec_sql "DROP VIEW IF EXISTS landuse_z12 CASCADE"
    exec_sql "DROP VIEW IF EXISTS landuse_z13toz14 CASCADE"
    # waterway views
    exec_sql "DROP VIEW IF EXISTS waterway_z8toz12 CASCADE"
    exec_sql "DROP VIEW IF EXISTS waterway_z13toz14 CASCADE"
    # water views
    exec_sql "DROP VIEW IF EXISTS water_z6toz12 CASCADE"
    exec_sql "DROP VIEW IF EXISTS water_z13toz14 CASCADE"
    # aeroway views
    exec_sql "DROP VIEW IF EXISTS aeroway_z12toz14 CASCADE"
    # barrier_line views
    exec_sql "DROP VIEW IF EXISTS barrier_line_z14 CASCADE"
    # building views
    exec_sql "DROP VIEW IF EXISTS building_z13 CASCADE"
    exec_sql "DROP VIEW IF EXISTS building_z14 CASCADE"
    # landuse views
    exec_sql "DROP VIEW IF EXISTS landuse_overlay_z7 CASCADE"
    exec_sql "DROP VIEW IF EXISTS landuse_overlay_z8 CASCADE"
    exec_sql "DROP VIEW IF EXISTS landuse_overlay_z9 CASCADE"
    exec_sql "DROP VIEW IF EXISTS landuse_overlay_z10 CASCADE"
    exec_sql "DROP VIEW IF EXISTS landuse_overlay_z11toz12 CASCADE"
    exec_sql "DROP VIEW IF EXISTS landuse_overlay_z13toz14 CASCADE"
    # tunnel views
    exec_sql "DROP VIEW IF EXISTS tunnel_z12toz14 CASCADE"
    # road views
    exec_sql "DROP VIEW IF EXISTS road_z5toz6 CASCADE"
    exec_sql "DROP VIEW IF EXISTS road_z7 CASCADE"
    exec_sql "DROP VIEW IF EXISTS road_z8toz10 CASCADE"
    exec_sql "DROP VIEW IF EXISTS road_z11 CASCADE"
    exec_sql "DROP VIEW IF EXISTS road_z12 CASCADE"
    exec_sql "DROP VIEW IF EXISTS road_z13 CASCADE"
    exec_sql "DROP VIEW IF EXISTS road_z14 CASCADE"
    # bridge views
    exec_sql "DROP VIEW IF EXISTS bridge_z12toz14 CASCADE"
    # admin views
    exec_sql "DROP VIEW IF EXISTS admin_z2toz6 CASCADE"
    exec_sql "DROP VIEW IF EXISTS admin_z7toz14 CASCADE"
    # place_label views
    exec_sql "DROP VIEW IF EXISTS place_label_z4toz5 CASCADE"
    exec_sql "DROP VIEW IF EXISTS place_label_z6 CASCADE"
    exec_sql "DROP VIEW IF EXISTS place_label_z7 CASCADE"
    exec_sql "DROP VIEW IF EXISTS place_label_z8 CASCADE"
    exec_sql "DROP VIEW IF EXISTS place_label_z9toz10 CASCADE"
    exec_sql "DROP VIEW IF EXISTS place_label_z11toz12 CASCADE"
    exec_sql "DROP VIEW IF EXISTS place_label_z13 CASCADE"
    exec_sql "DROP VIEW IF EXISTS place_label_z14 CASCADE"
    # water_label views
    exec_sql "DROP VIEW IF EXISTS water_label_z10 CASCADE"
    exec_sql "DROP VIEW IF EXISTS water_label_z11 CASCADE"
    exec_sql "DROP VIEW IF EXISTS water_label_z12 CASCADE"
    exec_sql "DROP VIEW IF EXISTS water_label_z13 CASCADE"
    exec_sql "DROP VIEW IF EXISTS water_label_z14 CASCADE"
    # poi_label views
    exec_sql "DROP VIEW IF EXISTS poi_label_z14 CASCADE"
    # road_label views
    exec_sql "DROP VIEW IF EXISTS road_label_z8toz10 CASCADE"
    exec_sql "DROP VIEW IF EXISTS road_label_z11 CASCADE"
    exec_sql "DROP VIEW IF EXISTS road_label_z12toz13 CASCADE"
    exec_sql "DROP VIEW IF EXISTS road_label_z14 CASCADE"
    # waterway_label views
    exec_sql "DROP VIEW IF EXISTS waterway_label_z8toz12 CASCADE"
    exec_sql "DROP VIEW IF EXISTS waterway_label_z13toz14 CASCADE"
    # housenum_label views
    exec_sql "DROP VIEW IF EXISTS housenum_label_z14 CASCADE"
}

function exec_sql() {
	local sql_cmd="$1"
	PG_PASSWORD=$OSM_PASSWORD psql \
        --host="$DB_HOST" \
        --port=5432 \
        --dbname="$OSM_DB" \
        --username="$OSM_USER" \
        -c "$sql_cmd" || true
}

function merge_latest_diffs() {
    local pbf_file="$1"
    local latest_diffs_file="$2"
    local latest_pbf_file="$IMPORT_DATA_DIR/${pbf_file##*/}.latest.pbf"

    echo "Updating $pbf_file with changes $latest_diffs_file"
    osmconvert -v "$pbf_file" "$latest_diffs_file" -o="$latest_pbf_file"
    rm "$pbf_file"
    mv "$latest_pbf_file" "$pbf_file"
}

function import_pbf_diffs() {
    local pbf_file="$1"
    local latest_diffs_file="$IMPORT_DATA_DIR/latest.osc.gz"

    cd "$IMPORT_DATA_DIR"
    if [ "$OSM_UPDATE_BASEURL" = false ]; then
        osmupdate "$pbf_file" "$latest_diffs_file"
    else
        echo "Downloading diffs from $OSM_UPDATE_BASEURL"
        osmupdate -v \
            "$pbf_file" "$latest_diffs_file" \
            --base-url="$OSM_UPDATE_BASEURL"
    fi

    imposm3 diff \
        -connection "$PG_CONNECT" \
        -mapping "$MAPPING_YAML" \
        -cachedir "$IMPOSM_CACHE_DIR" \
        -diffdir "$IMPORT_DATA_DIR" \
        -dbschema-import "${DB_SCHEMA}" \
        "$latest_diffs_file"

    local timestamp=$(extract_timestamp "$latest_diffs_file")
    echo "Set $timestamp for latest updates from $latest_diffs_file"
    update_timestamp "$timestamp"


    merge_latest_diffs "$pbf_file" "$latest_diffs_file"
}

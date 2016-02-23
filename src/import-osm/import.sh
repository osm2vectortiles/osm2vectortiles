#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
readonly IMPOSM_CACHE_DIR=${IMPOSM_CACHE_DIR:-/data/cache}

readonly IMPOSM_BIN=${IMPOSM_BIN:-/imposm3}
readonly MAPPING_JSON=${MAPPING_JSON:-/usr/src/app/mapping.json}

readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

readonly DB_SCHEMA=${OSM_SCHEMA:-public}
readonly DB_HOST=$DB_PORT_5432_TCP_ADDR
readonly PG_CONNECT="postgis://$OSM_USER:$OSM_PASSWORD@$DB_HOST/$OSM_DB"

function download_pbf() {
    local pbf_url=$1
	wget -q  --directory-prefix "$IMPORT_DATA_DIR" --no-clobber "$pbf_url"
}

function import_pbf() {
    local pbf_file="$1"
    $IMPOSM_BIN import \
        -connection $PG_CONNECT \
        -mapping $MAPPING_YAML \
        -overwritecache -cachedir=$IMPOSM_CACHE_DIR \
        -read $pbf_file \
        -write -dbschema-import=${DB_SCHEMA} -optimize -diff
}

function update_timestamp() {
    local timestamp="$1"
	exec_sql "UPDATE osm_admin SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_aero_lines SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_aero_polygons SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_barrier_lines SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_barrier_polygons SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_buildings SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_buildings_gen0 SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_countries SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_housenumbers_points SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_housenumbers_polygons SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_landusages SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_landusages_gen0 SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_landusages_gen1 SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_marine SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_ocean_polygons SET timestamp='$timestamp'"
	exec_sql "UPDATE osm_places SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_poi_points SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_poi_polygons SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_roads SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_states SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_water_lines SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_water_polygons SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE osm_water_polygons_gen1 SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE seas SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE states SET timestamp='$timestamp' WHERE timestamp IS NULL"
	exec_sql "UPDATE water_polygons SET timestamp='$timestamp' WHERE timestamp IS NULL"
}

function add_timestamp_column() {
	exec_sql "ALTER TABLE osm_admin ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_aero_lines ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_aero_polygons ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_barrier_lines ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_barrier_polygons ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_buildings ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_buildings_gen0 ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_countries ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_housenumbers_points ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_housenumbers_polygons ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_landusages ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_landusages_gen0 ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_landusages_gen1 ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_marine ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_ocean_polygons ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_places ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_poi_points ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_poi_polygons ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_roads ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_states ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_water_lines ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_water_polygons ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE osm_water_polygons_gen1 ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE seas ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE states ADD COLUMN timestamp timestamp"
	exec_sql "ALTER TABLE water_polygons ADD COLUMN timestamp timestamp"
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

function import_diff_changes() {
    local changes_dir="$1"
    $IMPOSM_BIN diff \
        -connection $PG_CONNECT \
        -mapping $MAPPING_YAML \
        -cachedir=$IMPOSM_CACHE_DIR \
        -dbschema-import=${DB_SCHEMA} $changes_dir/*.osc.gz
}

function import_single_pbf() {
    if [ "$(ls -A $IMPORT_DATA_DIR/*.pbf 2> /dev/null)" ]; then
        local pbf_file
        for pbf_file in "$IMPORT_DATA_DIR"/*.pbf; do
            import_pbf $pbf_file
            break
        done
        exit 0
    else
        echo "No PBF files for import found."
        echo "Please mount the $IMPORT_DATA_DIR volume to a folder containing OSM PBF files."
        exit 404
    fi
}

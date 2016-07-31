#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly OSM_DB=${OSM_DB:-gis}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

readonly DB_SCHEMA=${OSM_SCHEMA:-public}
readonly DB_HOST=$DB_PORT_5432_TCP_ADDR
readonly PG_CONNECT="postgis://$OSM_USER:$OSM_PASSWORD@$DB_HOST/$OSM_DB"

function import_all() {
    local pbf_file="$1"
    osm2pgsql -d "$OSM_DB" -U "$OSM_USER" -W "$OSM_PASSWORD" -H "$DB_HOST" "$pbf_file" --create --slim --cache 1000 --number-process 2 --hstore --multi-geometry --style openstreetmap-carto.style

    ./get-shapefiles.sh

    psql -d gis -f indexes.sql

    make reindexshapefiles postgresql-indexes
}

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

    echo $pbf_file
    export pgpassword="$OSM_PASSWORD"
    osm2pgsql --create --slim --cache 1000 --number-processes 2 --hstore  --style "/openstreetmap-carto-vector-tiles/openstreetmap-carto.style" --multi-geometry --database="$OSM_DB" --username="$OSM_USER" --host="$DB_HOST" "$pbf_file"
    echo "Done import"

    cd /openstreetmap-carto-vector-tiles/

    psql -d "$OSM_DB" -h "$DB_HOST" -U "$OSM_USER" -f /openstreetmap-carto-vector-tiles/indexes.sql 
    PGOPTIONS='--client-min-messages=fatal' psql -d "$OSM_DB" -h "$DB_HOST" -U "$OSM_USER" -f add-indexes.sql || true
    echo "Done indexing"

    bash /openstreetmap-carto-vector-tiles/get-shapefiles.sh # Might need to put this into db
    make install-node-modules
    make reindexshapefiles #Might need to put this into db
}

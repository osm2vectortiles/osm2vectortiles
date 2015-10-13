#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly OSM_DB=${OSM_DB:-osm}
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}

function create_osm_db() {
    echo "Creating database $OSM_DB with owner $OSM_USER"
    PGUSER="$POSTGRES_USER" psql --dbname="$POSTGRES_DB" <<-'EOSQL'
		CREATE USER $OSM_DB WITH PASSWORD '$OSM_PASSWORD';
		CREATE DATABASE $OSM_DB WITH TEMPLATE template_postgis OWNER $OSM_USER;
	EOSQL
}

function main() {
    create_osm_db
}

main

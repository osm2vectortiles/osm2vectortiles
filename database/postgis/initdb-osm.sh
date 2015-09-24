#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

OSM_DB=${OSM_DB:-osm}
OSM_USER=${OSM_USER:-osm}
OSM_PASS=${OSM_PASS:-osm}

# perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# create OSM database
echo "Creating database $OSM_DB with owner $OSM_USER"
psql --dbname="$POSTGRES_DB" <<- EOSQL
CREATE USER $OSM_DB WITH PASSWORD '$OSM_PASS';
CREATE DATABASE $OSM_DB WITH TEMPLATE template_postgis OWNER $OSM_USER;
EOSQL

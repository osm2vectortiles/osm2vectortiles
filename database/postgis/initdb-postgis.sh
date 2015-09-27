#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

# perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# create the 'template_postgis' template db
psql --dbname="$POSTGRES_DB" <<- 'EOSQL'
CREATE DATABASE template_postgis;
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
EOSQL

# load PostGIS into both template_database and $POSTGRES_DB
cd "/usr/share/postgresql/$PG_MAJOR/contrib/postgis-$POSTGIS_MAJOR"
for DB in template_postgis "$POSTGRES_DB"; do
	echo "Loading PostGIS into $DB"
	psql --dbname="$DB" <<-'EOSQL'
		CREATE EXTENSION postgis;
		CREATE EXTENSION hstore;
		CREATE EXTENSION postgis_topology;
		CREATE EXTENSION fuzzystrmatch;
		CREATE EXTENSION postgis_tiger_geocoder;
	EOSQL
done

echo "Loading vt-util functions into template_postgis"
psql --dbname="template_postgis" -f "$VT_UTIL_DIR/postgis-vt-util.sql"

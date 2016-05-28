# Intended for Ubuntu 14.04
cd

apt-get update
apt-get install -y --no-install-recommends postgresql-9.3-postgis wget ca-certificates postgresql 

export CARTODB_DIR=/opt/cartodb-postgresql
export VT_UTIL_DIR=/opt/postgis-vt-util 
export VT_UTIL_URL="https://raw.githubusercontent.com/mapbox/postgis-vt-util/v1.0.0/postgis-vt-util.sql"
export PG_MAJOR=9.3
export PGDATA=/etc/postgresql/$PG_MAJOR/main/
export POSTGIS_MAJOR=2.2
export POSTGRES_USER=postgres
export POSTGRES_DB=osm

echo "local all all peer" > $PGDATA/pg_hba.conf
echo "host all all 127.0.0.1/32 trust" >> $PGDATA/pg_hba.conf
echo "host all all ::1/128 trust" >> $PGDATA/pg_hba.conf
echo "host all all 192.168.0.0/16 trust" >> $PGDATA/pg_hba.conf

service postgresql restart

mkdir -p /opt/postgis-vt-util
wget -P /opt/postgis-vt-util --quiet "$VT_UTIL_URL"

# install github.com/elitwin/pgtune 
wget https://github.com/elitwin/pgtune/tarball/master
tar -xzf master
mv elitwin* pgtune
rm -rf master elitwin*

python pgtune/pgtune --version 9.3 --connections 30 --type DW  --input-config $PGDATA/postgresql.conf --output-config $PGDATA/postgresql.conf.pgtune

function create_template_postgis() {
    PGUSER="$POSTGRES_USER" psql --dbname="$POSTGRES_DB" <<-'EOSQL'
		CREATE DATABASE template_postgis;
		UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
	EOSQL
}

function execute_sql_into_template() {
    local sql_file="$1"
    PGUSER="$POSTGRES_USER" psql --dbname="template_postgis" -f "$sql_file"
}

function install_vt_util() {
    echo "Loading vt-util functions into template_postgis"
    execute_sql_into_template "$VT_UTIL_DIR/postgis-vt-util.sql"
}

function create_postgis_extensions() {
    cd "/usr/share/postgresql/$PG_MAJOR/contrib/postgis-$POSTGIS_MAJOR"
    local db
    for db in template_postgis "$POSTGRES_DB"; do
        echo "Loading PostGIS into $db"
        PGUSER="$POSTGRES_USER" psql --dbname="$db" <<-'EOSQL'
			CREATE EXTENSION postgis;
			CREATE EXTENSION postgis_topology;
			CREATE EXTENSION hstore;
			CREATE EXTENSION pgcrypto;
		EOSQL
    done
}

create_template_postgis
create_postgis_extensions
install_vt_util

mv $PGDATA/postgresql.conf $PGDATA/postgresql.conf.backup
mv $PGDATA/postgresql.conf.pgtune $PGDATA/postgresql.conf

create_osm_db

rm -f /docker-entrypoint-initdb.d/postgis.sh
cp ./osmdw_pgtune.sh /docker-entrypoint-initdb.d/05_osmdw_pgtune.sh
cp ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
cp ./initdb-osm.sh /docker-entrypoint-initdb.d/20_osm.sh

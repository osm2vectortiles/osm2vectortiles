# Intended for Ubuntu 14.04, run as root
cd

echo "Install necessary tools"
apt-get update
apt-get install -y --no-install-recommends postgis-2.1 wget ca-certificates postgresql postgresql-contrib postgresql-9.3-postgis-2.1

export CARTODB_DIR=/opt/cartodb-postgresql
export VT_UTIL_DIR=/opt/postgis-vt-util 
export VT_UTIL_URL="https://raw.githubusercontent.com/mapbox/postgis-vt-util/v1.0.0/postgis-vt-util.sql"
export PG_MAJOR=9.3
export PGDATA=/etc/postgresql/$PG_MAJOR/main/
export POSTGIS_MAJOR=2.2
export POSTGRES_USER=postgres
export POSTGRES_DB=osm
export OSM_DB=${OSM_DB:-osm}
export OSM_USER=${OSM_USER:-osm}
export OSM_PASSWORD=${OSM_PASSWORD:-osm}

echo "Setting pg_hba.conf"
echo "local all all peer" > $PGDATA/pg_hba.conf
echo "host all all 127.0.0.1/32 trust" >> $PGDATA/pg_hba.conf
echo "host all all ::1/128 trust" >> $PGDATA/pg_hba.conf
echo "host all all 192.168.0.0/16 trust" >> $PGDATA/pg_hba.conf

echo "Getting PostGIS-vt-util"
mkdir -p /opt/postgis-vt-util
wget -P /opt/postgis-vt-util --quiet "$VT_UTIL_URL"

echo "Install and run PGtune" 
wget https://github.com/elitwin/pgtune/tarball/master
tar -xzf master
mv elitwin* pgtune
rm -rf master elitwin* pgtune
python pgtune/pgtune --version 9.3 --connections 30 --type DW  --input-config $PGDATA/postgresql.conf --output-config $PGDATA/postgresql.conf.pgtune

mv $PGDATA/postgresql.conf $PGDATA/postgresql.conf.backup
mv $PGDATA/postgresql.conf.pgtune $PGDATA/postgresql.conf
echo "listen_addresses='*'" >> $PGDATA/postgresql.conf

service postgresql restart

function create_template_postgis() {
    psql -U $POSTGRES_USER -h localhost -c "CREATE DATABASE template_postgis;"
    psql -U $POSTGRES_USER -h localhost -c "UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';"
}

function execute_sql_into_template() {
    psql -U $POSTGRES_USER -h localhost -d "template_postgis" -f "$1"
}

function install_vt_util() {
    execute_sql_into_template "$VT_UTIL_DIR/postgis-vt-util.sql"
}

function create_postgis_extensions() {
    psql -U $POSTGRES_USER -h localhost  -d template_postgis -c "CREATE EXTENSION postgis; CREATE EXTENSION postgis_topology; CREATE EXTENSION hstore; CREATE EXTENSION pgcrypto;"
}

function create_osm_db() {
    psql -U $POSTGRES_USER -h localhost -c "CREATE USER $OSM_USER WITH PASSWORD '$OSM_PASSWORD';"
    psql -U $POSTGRES_USER -h localhost  -c "CREATE DATABASE $OSM_DB WITH TEMPLATE template_postgis OWNER $OSM_USER;"
}

echo "Creating Template"
create_template_postgis
echo "Creating PostGIS Extensions"
create_postgis_extensions
echo "Loading vt-util functions into template_postgis"
install_vt_util
echo "Creating database $OSM_DB with owner $OSM_USER"
create_osm_db

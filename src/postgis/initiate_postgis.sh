sudo apt-get update
suddo apt-get install -y --no-install-recommends wget ca-certificates

export CARTODB_DIR=/opt/cartodb-postgresql
export VT_UTIL_DIR=/opt/postgis-vt-util 
export VT_UTIL_URL="https://raw.githubusercontent.com/mapbox/postgis-vt-util/v1.0.0/postgis-vt-util.sql"

mkdir -p /opt/postgis-vt-util
wget -P /opt/postgis-vt-util --quiet "$VT_UTIL_URL"

# install github.com/elitwin/pgtune 
wget https://github.com/elitwin/pgtune/tarball/master
tar -xzf master
mv elitwin* pgtune
rm -rf master

rm -f /docker-entrypoint-initdb.d/postgis.sh
cp ./osmdw_pgtune.sh /docker-entrypoint-initdb.d/05_osmdw_pgtune.sh
cp ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
cp ./initdb-osm.sh /docker-entrypoint-initdb.d/20_osm.sh

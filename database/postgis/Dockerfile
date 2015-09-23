FROM mdillon/postgis:9.4

# copy new initdb file which creates the hstore extension
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh

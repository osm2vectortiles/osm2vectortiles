#!/bin/bash

TYPE=$1
AREA=$2

DATA_DIR=${DATA_DIR:-/data}
METRO_DIR=$DATA_DIR/metro

IMPOSM_BIN=${IMPOSM_BIN:-/imposm3}
IMPOSM_CACHE_DIR=$DATA_DIR/cache
MAPPING_JSON=${MAPPING_JSON:-/usr/src/app/mapping.json}

DB_NAME=osm
DB_USER=osm
DB_PASS=osm

if [[ $TYPE == 'metro' ]]; then
    TYPE_DIR=$METRO_DIR
    FILENAME=${AREA}.osm.pbf
    URL="https://s3.amazonaws.com/metro-extracts.mapzen.com/${FILENAME}"
fi

PBF_FILEPATH=$TYPE_DIR/$FILENAME
DIR=$(dirname $PBF_FILEPATH)

mkdir -p $DIR
cd $DIR && curl -O $URL

mkdir -p $IMPOSM_CACHE_DIR

DB_SCHEMA=public
PG_CONNECT="postgis://$DB_USER:$DB_PASS@$DB_PORT_5432_TCP_ADDR/$DB_NAME"
$IMPOSM_BIN import -connection $PG_CONNECT -mapping $MAPPING_JSON -appendcache -cachedir=$IMPOSM_CACHE_DIR -read $PBF_FILEPATH
$IMPOSM_BIN import -connection $PG_CONNECT -mapping $MAPPING_JSON -appendcache -cachedir=$IMPOSM_CACHE_DIR -write -dbschema-import=${DB_SCHEMA}

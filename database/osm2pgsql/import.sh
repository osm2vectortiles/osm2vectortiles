#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

# connection setup
OSM_HOST=$DB_PORT_5432_TCP_ADDR
OSM_DB=${OSM_DB:-osm}
OSM_USER=${OSM_USER:-osm}
OSM_PASSWORD=${OSM_PASSWORD:-osm}

# mounted data volume containing the pbfs
IMPORT_DATA_DIR=${IMPORT_DATA_DIR:-/data/import}
CACHE_DIR=${CACHE_DIR:-/data/cache}

# use all available cores for import
AVAILABLE_PROC=$(nproc)
PROC_NUM=${PROC_NUM:-$AVAILABLE_PROC}

# choose a big enough cache for the nodes
NODES_CACHE=${NODES_CACHE:-2000}


if [ "$(ls -A $IMPORT_DATA_DIR/*.pbf 2> /dev/null)" ]; then
    for PBF_FILE in "$IMPORT_DATA_DIR"/*.pbf; do
        PGPASSWORD=$OSM_PASSWORD osm2pgsql -d $OSM_DB -U $OSM_USER -H $OSM_HOST --create --slim --flat-nodes $CACHE_DIR/nodes.bin -C $NODES_CACHE --number-processes $PROC_NUM --hstore $PBF_FILE
        echo "Successfully imported $PBF_FILE"
        break
    done
else
    echo "No PBF files for import found."
    echo "Please mount the $IMPORT_DATA_DIR volume to a folder containing OSM PBF files."
    exit 404
fi

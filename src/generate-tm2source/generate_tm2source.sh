#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

git clone https://github.com/stirringhalo/openstreetmap-carto-vector-tiles.git

cd openstreetmap-carto-vector-tiles && python convert_ymls.py --input project.yaml --tm2source --output /osm2vectortiles.tm2source/data.yml

sed -i "/dbname: gis/adbname: gis\n    port:5432\n    user: osm\n    password: osm\n    host: db" /osm2vectortiles.tm2source/data.yml

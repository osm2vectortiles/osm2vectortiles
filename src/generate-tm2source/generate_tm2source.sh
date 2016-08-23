#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

git clone https://github.com/stirringhalo/openstreetmap-carto-vector-tiles.git

rm -f /data/tm2source/data.yml

cd openstreetmap-carto-vector-tiles && python convert_ymls.py --input project.yaml --tm2source --output /data/tm2source/data.yml

sed -i "/dbname: gis/a\    port: 5432\n    user: osm\n    password: osm\n    host: db\n    max_size: 512" /data/tm2source/data.yml
sed -i 's/20037508/20037508.34/g' /data/tm2source/data.yml
sed -i '/metatile/d' /data/tm2source/data.yml
sed -i '/scale: 1/d' /data/tm2source/data.yml
sed -i '/format:/d' /data/tm2source/data.yml
echo 'attribution: "<a href=\"http://www.openstreetmap.org/about/\" target=\"_blank\">&copy; OpenStreetMap contributors</a>"' >> /data/tm2source/data.yml 

#sed -i '/bounds: *id001/d' /data/tm2source/data.yml

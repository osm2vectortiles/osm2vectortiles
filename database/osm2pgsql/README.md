## Import using different tool

```
docker run --rm --name osm2pgsql \
    -v /data/import:/data/import \
    --link postgis:db \
    osm2vectortiles/osm2pgsql
```

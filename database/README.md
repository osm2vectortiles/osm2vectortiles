# OSM Import into PostGIS

Infrastructure to create a docker based OSM Postgis database
to create vector tiles from.

The database is separated from the import process. You can switch
out the database container with a existing database.

# Import

## Run the PostGIS container

Mount the folder where the database data should be stored in.

```
docker run --name postgis \
    -v $(pwd):/var/lib/postgresql/data
    -d osm2vectortiles/postgis
```

## Run the imposm import

Mount the imposm cache.
Supports metro extracts for now.
https://mapzen.com/data/metro-extracts


```
docker run --rm --name imposm \
    -v $(pwd):/data \
    -t osm2vectortiles/imposm \
    import.sh metro zurich_switzerland
```

## Docker Build

The Postgis container is based of [mdillon/postgis](https://github.com/appropriate/docker-postgis)
with the additional `hstore` extension.

```
cd postgis
docker build -t osm2vectortiles/postgis
```

The imposm3 container is based of
[wilsaj/everything-is-osm](https://github.com/wilsaj/everything-is-osm/tree/master/docker/imposm3).

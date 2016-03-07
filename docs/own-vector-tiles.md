---
layout: page
title: Create your own Vector Tiles
published: true
---

# Create your own vector tiles

We use Docker extensively for development and deployment.
The easiest way to get started is using [Docker Compose](https://www.docker.com/docker-compose).

Clone the [osm2vectortiles](https://github.com/osm2vectortiles/osm2vectortiles) project.

```
git clone https://github.com/osm2vectortiles/osm2vectortiles.git
```

Start up your PostGIS container with the data container attached.

```
docker-compose up -d postgis
```

Download a PBF and put it into the local `import` directory.
You can use extracts from [Mapzen](https://mapzen.com/data/metro-extracts)
or [Geofabrik](http://download.geofabrik.de/)

```
wget https://s3.amazonaws.com/metro-extracts.mapzen.com/zurich_switzerland.osm.pbf
```

Now you need to import the PBF files into PostGIS.

```
docker-compose up import-osm
```

Now you need to import several external data sources.
Import water polygons from [OpenStreetMapData.com](http://openstreetmapdata.com/data/water-polygons).

```
docker-compose up import-water
```

Import [Natural Earth](http://www.naturalearthdata.com/) data for lower zoom levels.

```
docker-compose up import-natural-earth
```

Import custom country, sea and state labels.

```
docker-compose up import-labels
```

Now import custom SQL functions used in the source project.

```
docker-compose up import-sql
```

Update the scaleranks of OSM places with data from Natural Earth.

```
docker-compose up update-scaleranks
```

Edit the `BBOX` environement variable in the docker-compose.yml file to match your desired extract.

```
export:
  image: "osm2vectortiles/export"
  command: ./export-local.sh
  volumes:
   - ./export:/data/export
   - ./open-streets.tm2source:/data/tm2source
  links:
   - pgbouncer:db
  environment:
    BBOX: "8.4375 46.07323062540838 9.84375 47.040182144806664"
    MIN_ZOOM: "8"
    MAX_ZOOM: "14"
```

Export the data as MBTiles file to the `export` directory.

```
docker-compose up export
```

Optional: Merge lower zoom levels (z0 to z5) into extract

Prerequisite: sqlite3 installed

Download lower zoom level extract:

```
wget -P ./export/ https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/world_z0-z5.mbtiles
```

Merge lower zoom levels into extract:

```
local mbtiles_source="./export/world_z0-z5.mbtiles"
local mbtiles_dest="./export/zurich.mbtiles"
echo "
PRAGMA journal_mode=PERSIST;
PRAGMA page_size=80000;
PRAGMA synchronous=OFF;
ATTACH DATABASE '$mbtiles_source' AS source;
REPLACE INTO map SELECT * FROM source.map;
REPLACE INTO images SELECT * FROM source.images;"\
| sqlite3 "$mbtiles_dest"
```

Serve the tiles as raster tiles from `export` directory.

```
docker-compose up serve
```

The tile server will no be visible on the docker host on port `8080`.
You can now see extract rendered as `Open Streets v1.0` and if you have
style projects in your directory the rendered raster map as well.

![Tessera Overview](/media/local_serve_container_tessera_overview.png)

## Docker Images

The workflow consists of several prebuilt Docker images.

| Image                             | Size                                                                                                               |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| klokantech/tileserver-mapnik      | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/klokantech/tileserver-mapnik/latest.svg)]()            |
| osm2vectortiles/export            | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/export/latest.svg)]()           |
| osm2vectortiles/import-external   | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/import-external/latest.svg)]()  |
| osm2vectortiles/import-sql        | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/import-sql/latest.svg)]()       |
| osm2vectortiles/import-osm        | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/import-osm/latest.svg)]()       |
| osm2vectortiles/update-scaleranks | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/update-scaleranks/latest.svg)]() |
| osm2vectortiles/postgis           | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/postgis/latest.svg)]()          |
| osm2vectortiles/pgbouncer         | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/pgbouncer/latest.svg)]()        |

---
layout: page
title: Own Vector Tiles
published: true
---

# Create your own vector tiles

We use Docker extensively for development and deployment. The easiest way to get started is using [Docker Compose](https://www.docker.com/docker-compose).

Clone the osm2vectortiles project.

```
git clone https://github.com/osm2vectortiles/osm2vectortiles.git
```

Start up your PostGIS container with the data container attached.

```
docker-compose up -d postgis
```

Download a PBF and put it into the local `import` directory.

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

Import Natural Earth data for lower zoom levels.

```
docker-compose up import-natural-earth
```

Import custom country, sea and state labels.

```
docker-compose up import-labels
```

Now import custom SQL functions.

```
docker-compose up import-sql
```

Update the scaleranks of OSM places.

```
docker-compose up update-scaleranks
```

Export the data as MBTiles file to the `export` directory.

```
docker-compose up export
```

Serve the tiles as raster tiles from `export` directory.

```
docker-compose up serve
```

## Docker Images

The workflow consists of several prebuilt Docker images.

| Image                             | Size                                                                                                               |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| osm2vectortiles/serve             | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/serve/latest.svg)]()            |
| osm2vectortiles/export            | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/export/latest.svg)]()           |
| osm2vectortiles/import-external   | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/import-external/latest.svg)]()  |
| osm2vectortiles/import-sql        | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/import-sql/latest.svg)]()       |
| osm2vectortiles/import-osm        | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/import-osm/latest.svg)]()       |
| osm2vectortiles/update-scaleranks | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/update-scaleranks/latest.svg)]() |
| osm2vectortiles/postgis           | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/postgis/latest.svg)]()          |
| osm2vectortiles/pgbouncer         | [![ImageLayers Size](https://img.shields.io/imagelayers/image-size/osm2vectortiles/pgbouncer/latest.svg)]()        |

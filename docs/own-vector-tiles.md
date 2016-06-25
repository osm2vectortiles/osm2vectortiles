---
layout: page
title: Generate your own Vector Tiles
published: true
---

# Generate your own vector tiles

In this tutorial you will learn how to create your own vector tiles with the help of the OSM2VectorTiles toolset. In order to run through the following steps you need to have [docker](https://docs.docker.com/engine/installation/){:target="_blank"} and [docker-compose](https://docs.docker.com/compose/install/){:target="_blank"} installed.

Clone the [OSM2VectorTiles](https://github.com/osm2vectortiles/osm2vectortiles){:target="_blank"} repository and change directory to it.

```
git clone https://github.com/osm2vectortiles/osm2vectortiles.git
cd ./osm2vectortiles
```

Start up your PostGIS container with the data container attached.

```
docker-compose up -d postgis
```

Download a PBF and put it into the local `import` directory.
You can use extracts from [Mapzen](https://mapzen.com/data/metro-extracts){:target="_blank"}
or [Geofabrik](http://download.geofabrik.de/){:target="_blank"}

```
wget https://s3.amazonaws.com/metro-extracts.mapzen.com/zurich_switzerland.osm.pbf -P ./import
```

Now you need to import several external data sources.
Import water polygons from [OpenStreetMapData.com](http://openstreetmapdata.com/data/water-polygons){:target="_blank"}, [Natural Earth](http://www.naturalearthdata.com/){:target="_blank"} data for lower zoom levels and custom country, sea and state labels.

```
docker-compose up import-external
```

With the next command the downloaded PBF file gets imported into PostGIS.

```
docker-compose up import-osm
```

The following command imports custom SQL utilities such as functions and views, which are needed to create the vector tiles.

```
docker-compose up import-sql
```

**Important:** Edit the `BBOX` environement variable in the docker-compose.yml file to match your desired extract.

```
export:
  image: "osm2vectortiles/export"
  command: ./export-local.sh
  volumes:
   - ./export:/data/export
   - ./osm2vectortiles.tm2source:/data/tm2source
  links:
   - postgis:db
  environment:
    BBOX: "8.34,47.27,8.75,47.53"
    MIN_ZOOM: "8"
    MAX_ZOOM: "14"
```

Finally, the following command generates the vector tiles and creates an MBTiles file in the `export` directory.

```
docker-compose up export
```

In order to display your vector tiles follow the [getting started](/docs/getting-started) tutorial.

**Optional:** Merge lower zoom levels (z0 to z5) into extract (_prerequisite:_ sqlite3 installed)

Download lower zoom level extract.

```bash
wget -P ./export/ https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v2.0/planet_z0-z5.mbtiles
```

Download the `patch.sh` script from [the Mapbox mbutil project](https://github.com/mapbox/mbutil){:target="_blank"}.

```bash
wget https://raw.githubusercontent.com/mapbox/mbutil/master/patch
chmod +x patch
```

Merge lower zoom levels into extract.

```bash
./patch "./export/planet_z0-z5.mbtiles" "./export/zurich.mbtiles"
```

---
layout: page
title: Generate your own Vector Tiles
published: true
---

# Generate your own vector tiles

We use Docker extensively for development and deployment.
The easiest way to get started is using [Docker Compose](https://www.docker.com/docker-compose){:target="_blank"}.

Clone the [OSM2VectorTiles](https://github.com/osm2vectortiles/osm2vectortiles){:target="_blank"} project.

```
git clone https://github.com/osm2vectortiles/osm2vectortiles.git
```

Start up your PostGIS container with the data container attached.

```
docker-compose up -d postgis
```

Download a PBF and put it into the local `import` directory.
You can use extracts from [Mapzen](https://mapzen.com/data/metro-extracts){:target="_blank"}
or [Geofabrik](http://download.geofabrik.de/){:target="_blank"}

```
wget https://s3.amazonaws.com/metro-extracts.mapzen.com/zurich_switzerland.osm.pbf
```

Now you need to import several external data sources.
Import water polygons from [OpenStreetMapData.com](http://openstreetmapdata.com/data/water-polygons){:target="_blank"}, [Natural Earth](http://www.naturalearthdata.com/){:target="_blank"} data for lower zoom levels and custom country, sea and state labels.

```
docker-compose up import-external
```

Now you need to import the downloaded PBF file into PostGIS.

```
docker-compose up import-osm
```

Now import custom SQL functions used in the source project.

```
docker-compose up import-sql
```

Edit the `BBOX` environement variable in the docker-compose.yml file to match your desired extract.

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

Export the data as MBTiles file to the `export` directory.

```
docker-compose up export
```

Optional: Merge lower zoom levels (z0 to z5) into extract (prerequisite: sqlite3 installed)

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

Serve the tiles as raster tiles from `export` directory.

```
docker-compose up serve
```

The tile server will no be visible on the docker host on port `8080`.
You can now see extract rendered as `Open Streets v1.0` and if you have
style projects in your directory the rendered raster map as well.

![Tessera Overview](/media/local_serve_container_tessera_overview.png)

# osm2vectortiles [![Build Status](https://travis-ci.org/geometalab/osm2vectortiles.svg)](https://travis-ci.org/geometalab/osm2vectortiles)

Create [Mapbox Streets](https://www.mapbox.com/developers/vector-tiles/mapbox-streets-v5) compatible vector tiles for custom styling with [Mapbox Studio Classic](https://www.mapbox.com/mapbox-studio-classic/) and provide easy deployment methods.

## Get started

### Create a custom OSM base map

TODO: Create documentation for cartographer

### Deploy a custom OSM base map

TODO: Create documentation for sysadmin

## Components

The project consists of several components.

### Import

Import toolchain based on [Imposm 3](https://github.com/omniscale/imposm3) to
import [OpenStreetMap data](http://wiki.openstreetmap.org/wiki/Downloading_data)
into a [PostGIS](http://postgis.net/) database.
The mapping is optimized for fast generation of vectortiles.

![Import Step](https://github.com/manuelroth/osm2vectortiles-thesis/raw/master/source/figures/import_step.png)

### Export

Export toolchain consisting of a custom `tm2source` project based on the import mapping and
tools to scale exporting of the vectortiles horizontally.

![Export Step](https://github.com/manuelroth/osm2vectortiles-thesis/raw/master/source/figures/export_step.png)

### Tileserver

A very easy tileserver where you can simply drop in your `tm2` style project and our produced `mbtiles` file
and it will serve a custom styled OSM map.

![Tileserver Step](https://github.com/manuelroth/osm2vectortiles-thesis/raw/master/source/figures/tileserver_step.png)

## Flow

![High level flow of the two containers](https://cloud.githubusercontent.com/assets/59284/9849871/2a7b56a0-5aef-11e5-8f79-b3fd673bd0e6.jpg)

## Development

We use Docker extensively for development and deployment.

Start up your PostGIS container with the data container attached.

```
docker-compose up -d postgis
```

Import PBF files from the local `import` directory.
The import container will automatically download a PBF of Zurich for testing.

```
docker-compose run imposm3
```

Import SHP files from the local `import` directory. Or if there is now shapefile available the container will automatically download the water polygons shapefile from [OpenStreetMapData.com](http://openstreetmapdata.com/)

```
docker-compose run importwater
```

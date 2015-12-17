---
layout: page
title: Serve Raster Tiles with Docker
published: true
---

# Serve Raster Tiles with Docker

You can render raster tiles from a Mapbox Studio Classic **.tm2** style project and a vector tile MBTiles file
with the help of Docker and [tileserver-mapnik](https://github.com/klokantech/tileserver-mapnik).

For a single map you can serve up to 50 users concurrently with a standard 4GB VPS server with Docker installed.

## Preparation

1. Download MBTiles
2. Clone a **tm2** project (visual style)
3. Add both to the same directory

### Download MBTiles

On the server download your desired extract of a country or the
entire world MBTiles of the [Downloads page](/downloads).

```bash
wget -c https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/world.mbtiles
```

You can also download a smaller extract like Zurich.

```bash
wget -c https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/zurich.mbtiles
```

### Clone the Style Project

Clone your custom style project or in this example the official OSM Bright style.

```bash
git clone https://github.com/mapbox/mapbox-studio-osm-bright.tm2.git
```

## Run the raster tile server

Make sure you have the style project and the MBTiles file in the same directory.

```bash
├── mapbox-studio-osm-bright.tm2
└── world.mbtiles
```

Now run Docker via the command line to serve raster tiles.
The raster tiles will be exposed at port 8080 of your Docker host.

```bash
docker run -v $(pwd):/data -p 8080:80 klokantech/tileserver-mapnik
```

## Use the Raster Tiles

If you visit your Docker host on port 8080 you should see your map appearing
in the interface. If you click on the map thumbnail you will get the configuration
of the most common GIS clients and mapping libraries.

![Mapping libraries configuration](/media/tileserver_docker_cmd.png)

Choose `Source code` in `Leaflet` to get the source code for e.g. Leaflet.

![Leaflet configuration](/media/leaflet_configuration_tileserver.png)

The server will now provide a TileJSON endpoint at the service URL of the map.
For this example the TileJSON endpoint is `http://192.168.99.101:8080/mapbox-studio-osm-bright/index.json`.
You need to reference this TileJSON endpoint in the Leaflet configuration.

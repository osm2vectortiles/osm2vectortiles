---
layout: page
title: Serve Raster Tiles with Docker
published: true
---

You can render raster tiles from a Mapbox Studio Classic **.tm2** style project and a vector tiles file
with the help of Docker and [tessera](https://github.com/mojodna/tessera).
For a single map you can serve up to 50 users concurrently with a standard 4GB VPS server with Docker installed.

## Preparation

1. Download MBTiles
2. Clone a visual style project
3. Add both to the same directory

### Download MBTiles

On the server download your desired extract of a country or the
entire world MBTiles from http://osm2vectortiles.org/data/download.html.

```bash
wget -c https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/world.mbtiles
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

## Use the Map from Leaflet

The server will now provide a TileJSON endpoint at the service URL of the map.
For this example the TileJSON endpoint is http://localhost/mapbox-studio-osm-bright/index.json.
You can reference this TileJSON endpoint in the leaflet configuration.

The HTML file will display a fullscreen Leaflet map using the raster tiles from our 
raster tile server as a base layer. You can now add additional layer on top of it or add interactivity.

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset=utf-8 />
    <title>A simple map</title>
    <meta name='viewport' content='initial-scale=1,maximum-scale=1,user-scalable=no' />
    <script src='https://api.mapbox.com/mapbox.js/v2.2.2/mapbox.js'></script>
    <link href='https://api.mapbox.com/mapbox.js/v2.2.2/mapbox.css' rel='stylesheet' />
    <style>
      body { margin:0; padding:0; }
      #map { position:absolute; top:0; bottom:0; width:100%; }
    </style>
  </head>
<body>
<div id='map'></div>
<script>
  var map = L.mapbox.map('map', 'mapbox.light', {
    minZoom: 8,
  }).setView([46.806, 8.091], 8);
  var overlay = L.mapbox.tileLayer('http://localhost/mapbox-studio-osm-bright/index.json').addTo(map);
</script>
</body>
</html>
```

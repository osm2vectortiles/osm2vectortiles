---
layout: page
title: Get started
published: true
---

# Introduction

This tutorial describes how to get a raster tile map with OSM Vector Tiles as data source.


## Result

You get a basic raster tile map similar to the map below.

<div class="map-preview" id="osm-bright-map"></div>

## Preparation

1. [Download](http://osm2vectortiles.org/data/download.html) an extract you want to serve.
2. [Download](https://github.com/mapbox/mapbox-studio-osm-bright.tm2.git) the visual style.
3. Add both to the same directory and make sure that the have the same name

```bash

tileserver
	tiles.mbtiles (Extract)
	tiles.tm2 (Style Project)
```

## Install Kitematic

1. [Download](https://www.docker.com/docker-toolbox) and install Kitematic. 
2. Start a new container by searching for `osm2vectortiles` and click create on the container called `serve`. 

![Search Container](/media/search_container.png)

## Kitematic Usage

When you start the container, it will complain about missing `tm2` style projects.

![Container started unsucessfully](/media/tileserver_kitematic_started.png)

Mount your the directory containing the `mbtiles` files and `tm2` style projects into the `/data` volume.

![Configured volumes for container](/media/tileserver_kitematic_volumes_configured.png)

Now restart the container. You should be up and running serving generated raster tiles.

![Container running and serving tiles](/media/tileserver_kitematic_running.png)

<script>
var brightMap = L.mapbox.map('osm-bright-map', 'http://rastertiles.osm2vectortiles.org/osm-bright/index.json').setView([53.390, 1.351], 6);
</script>
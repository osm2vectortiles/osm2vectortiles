---
layout: page
title: Display map with tileserver-mapnik
published: true
---

# Introduction

This tutorial describes how to get a raster tile map with OSM Vector Tiles as data source.

## Command Line

If you want to get started very quickly, just use the following commands.

```bash
wget https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/zurich.mbtiles
git clone https://github.com/mapbox/mapbox-studio-osm-bright.tm2.git
docker run -v $(pwd):/data klokantech/tileserver-mapnik
```
Note: The webserver is started on port 80 of the container. To access it you need to figure out the ip address of the container. Or just open kitematic and click on web preview.

![Container running and serving tiles](/media/tileserver_kitematic_running.png)

## Kitematic

### Preparation

1. [Download](http://osm2vectortiles.org/downloads) an extract you want to serve.
2. [Download](https://github.com/mapbox/mapbox-studio-osm-bright.tm2.git) the visual style.

### Install Kitematic

1. [Download](https://www.docker.com/docker-toolbox) and install Kitematic. 
2. Start a new container by searching for `klokantech/tileserver-mapnik` and click create. 

![Search Container](/media/search_container.png)

### Add mbtiles file and style

Drag and Drop the downloaded mbtiles file and style project.

![Add resources to tileserver](/media/tileserver_add_resources.png)

Click on web preview and you should see the map.

![Container running and serving tiles](/media/tileserver_kitematic_running.png)

---
layout: page
title: Create a new Style with Mapbox Studio Classic
published: true
---

# Create a new Style with Mapbox Studio Classic

You can use [the same resources from Mapbox](https://www.mapbox.com/help/getting-started-studio/)
for learning how to design maps with Mapbox Studio Classic. This tutorial will show you how to customize
the OSM Bright style.

Download [Mapbox Studo Classic](https://www.mapbox.com/mapbox-studio-classic/) to create your first map.

## Create new style project

Create a new style project based of OSM Bright. You can also start with a blank slate but it is easier
to get started from an existing style.

In `Styles and Resources` create a new style and choose `OSM Bright 2`. Then save your project.

![Create new project with Mapbox Studio Classic](/media/mapbox_classic_create_project.gif)

## Switch to osm2vectortiles

Now you are based of the vector tiles from Mapbox Streets. To use our free and Open Source vector tiles
you need to `Change Source` in `Layers`.

Enter the [TileJSON](https://github.com/mapbox/tilejson-spec) URL of our vectortiles server `https://osm2vectortiles.tileserver.com/v1.json`.
You can later replace this with your own vector tiles server if you want to serve everything by yourself.

Because our vector tiles are to a large part Mapbox Streets compatible you won't see any drastic changes.
In fact you could even continue styling your project with Mapbox Streets and make the switch at the deployment stage of the project.

![Switch to osm2vectortiles in Mapbox Studio Classic](/media/mapbox_classic_switch_osm2vectortiles.gif)

## Design your Map

Create a awesome map with a great design. We recommend the
[Mapbox Studio Classic Quickstart tutorial](https://www.mapbox.com/help/style-quickstart/)
to get a overview of all the options you can use to create good looking maps.
To get some inspiration you can
look at the [example maps](/maps) that work together with osm2vectortiles.

[![Map Gallery of maps made with osm2vectortiles](/media/sample_map_gallery.gif)](/maps)

## Deploy your Map

Learn [how to deploy a raster tile server with Docker](/docs/serve-raster-tiles-docker/)
or get started by [displaying your first raster based map locally](/docs/start/).

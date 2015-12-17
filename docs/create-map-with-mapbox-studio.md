---
layout: page
title: Create a new Style with new Mapbox Studio
published: true
---

# Create a new Style with new Mapbox Studio 

Mapbox Studio is the new map design platform by Mapbox.
Mapbox provides [great resources for getting started](https://www.mapbox.com/help/getting-started-mapbox-studio-1/) how to design your own maps.
This tutorial will show you how to customize the OSM Bright style for Mapbox GL.

Visit [the Mapbox Studio Editor](https://www.mapbox.com/studio/) and follow the tutorial.

## Create new style project

Create a new style project. Make sure you start of a base map that only requires Mapbox Streets.
A Mapbox Terrain equivalent is not available by osm2vectortiles.

In `Styles` create a new style, choose `Bright` and save your project.

![Create new project with new Mapbox Studio](/media/mapbox_studio_create_style.gif)

## Switch to osm2vectortiles

In the new Mapbox Studio you can no longer specify a
[TileJSON](https://github.com/mapbox/tilejson-spec) url of a custom vectortiles server.
Therefore it is best to work with the original Mapbox Streets v6 data in the editor
and make the switch to osm2vectortiles at the deployment step. This works because our vector tiles are
to a large part Mapbox Streets v6 compatible.

Because users have an upload limit for their own data sources you cannot upload the osm2vectortiles
world file to Mapbox Studio and style it directly.
However if you want to work with the real data you can choose
an extract which is quite small (below 100MB) and upload it to Mapbox Studio and work on this sample
extract to create your map.

## Download Mapbox GL Style JSON

In order to host your own Mapbox GL map you need to download the
[Mapbox GL style JSON](https://www.mapbox.com/mapbox-gl-style-spec/).

![Download Mapbox GL Style JSON](/media/download_mapbox_gl_style_json.png)

## Deploy your Map

Once you've downloaded the Mapbox GL Style JSON you need to modify it
to work together with osm2vectortiles.

The tutorial [how to display a Mapbox GL map explains this in detail](/docs/display-map-with-mapbox-gl/).

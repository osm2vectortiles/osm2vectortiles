---
layout: page
title: Create a new Style with new Mapbox Studio
published: true
---

# Create a new Style with new Mapbox Studio 

Mapbox Studio is the new Map design platform by Mapbox.
Mapbox provides [great resources for getting started](https://www.mapbox.com/help/getting-started-mapbox-studio-1/) how to design your own maps.
This tutorial will show you how to customize the OSM Bright style for Mapbox GL.

Visit [the Mapbox Studio Editor](https://www.mapbox.com/studio/) and follow the tutorial.

## Create new style project

Create a new style project. Make sure you start of a base map that only requires Mapbox Streets.
A Mapbox Terrain equivalent is not available by osm2vectortiles.

In `Styles` create a new style, choose `Bright` and save your project.

![Create new project with new Mapbox Studio](/media/apbox_studio_create_style.gif.gif)

## Switch to osm2vectortiles

In the new Mapbox Studio you can no longer specify a
[TileJSON](https://github.com/mapbox/tilejson-spec) url of a custom vectortiles server.
Therefore it is best to work with the original Mapbox Streets v6 data in the editor
and make the switch at the deployment step.

Because users have an upload limit for their own data sources you cannot upload the osm2vectortiles
world file to Mapbox Studio. However if you want to work with the real data you can choose
an extract which is quite small (below 100MB) and upload it to Mapbox Studio.

TODO: Explain how to do that

## Deploy your Map

TODO: Link to serve tutorial of Mapbox GL

---
layout: page
title: Create a new Style with new Mapbox Studio
published: true
---

# Create a new Style with new Mapbox Studio 

Mapbox Studio is the new map design platform by Mapbox.
Mapbox provides [great resources for getting started](https://www.mapbox.com/help/getting-started-mapbox-studio-1/){:target="_blank"} how to design your own maps.
This tutorial will show you how to customize the OSM Bright style for Mapbox GL.

Visit [the Mapbox Studio Editor](https://www.mapbox.com/studio/){:target="_blank"} and follow the tutorial.

## Create new style project

Create a new style project. Make sure you start of a base map that only requires Mapbox Streets.
A Mapbox Terrain equivalent is not available by OSM2VectorTiles.

In `Styles` create a new style, choose `Bright` and save your project.

![Create new project with new Mapbox Studio](/media/mapbox_studio_create_style.gif){:target="_blank"}

## Download Mapbox GL Style JSON

Once you are satisfied with your personal map you can download the
[Mapbox GL style JSON](https://www.mapbox.com/mapbox-gl-style-spec/){:target="_blank"}.

![Download Mapbox GL Style JSON](/media/download_mapbox_gl_style_json.png){:target="_blank"}

## Deploy your Map

Once you've downloaded the Mapbox GL Style JSON you need to modify it
to work together with OSM2VectorTiles. The [getting started tutorial](/docs/getting-started){:target="_blank"} explains how this can be done.

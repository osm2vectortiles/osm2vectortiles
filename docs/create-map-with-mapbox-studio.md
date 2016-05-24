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

## Download Mapbox GL Style

Once you are satisfied with your personal map you can download the
[Mapbox GL Style](https://www.mapbox.com/mapbox-gl-style-spec/){:target="_blank"}.

![Download Mapbox GL Style](/media/download_mapbox_gl_style_json.png){:target="_blank"}

## Deploy your Map

Once you've downloaded the Mapbox GL Style you need to modify it
to work together with OSM2VectorTiles. Ensure you are serving vector tiles as explained in the [getting started tutorial](/docs/getting-started/).

The downloaded Mapbox GL Style defines how each feature of the map should be styled and where the assets like vector tiles, fonts and sprites are stored. In order to use your personal style together with OSM2VectorTiles the references to vector tiles, fonts and sprites need to be updated like in the style example below.

<script src="https://gist.github.com/manuelroth/d67f1ae67dddbb659ff17a7bb854096d.js"></script>

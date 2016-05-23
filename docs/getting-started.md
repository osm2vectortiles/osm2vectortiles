---
layout: page
title: Getting Started
published: true
---

# Getting Started

In this tutorial you will learn how to serve vector tiles from a MBTiles file and how to display them in your browser.

## Serve Vector Tiles

In order to render your map with Mapbox GL JS you need install a simple tileserver
that supports serving vector tiles.


```bash
npm install -g tileserver-gl-light
```

Head over to the [Downloads](/downloads/) section and choose your country or city extract or even the entire planet as the vector tiles you want to serve.
The vector tiles are stored in the MBTiles SQLite database you downloaded now.

```bash
curl -o zurich.mbtiles https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v2.0/extracts/zurich_switzerland.mbtiles
```

Start the tileserver in the same directory.

```bash
tileserver-gl-light zurich.mbtiles
```

## Display a map in your browser

If you visit `localhost:8080` you will see an overview of predefined styles you can already use. You can now choose a map and copy the example full-screen HTML code from below. Put the HTML code into a `index.html` and open it with your browser.

Congratulations, you are now serving your own vector tiles and your own map!
You can now [create your own custom Mapbox GL style with Mapbox Studio](/docs/create-map-with-mapbox-studio/).

<img src="/media/tileserver-gl-light.png" align="center" style="max-width:600px" alt="Index page of tileserver-gl-light" />

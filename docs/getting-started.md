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
npm install -g tileserver-vector
```

Apart from the vector tiles you also need to serve the fonts and icons needed in your styles.
We prepared a repository containing Mapbox GL example styles and the necessary font and icon files.

```bash
git clone https://github.com/osm2vectortiles/mapbox-gl-styles.git
cd mapbox-gl-styles
```

The most essential part is choosing the vector tiles you want to serve.
Head over to the [Downloads]() section and choose your country or city extract or even the entire planet.
The vector tiles are stored in the MBTiles SQLite database you downloaded now.
Download the MBTiles file into the same directory and name it `osm2vectortiles.mbtiles`.

```bash
curl -o osm2vectortiles.mbtiles https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/zurich.mbtiles
```

Now start the tileserver in the same directory.

```bash
tileserver-vector
```

If you visit `localhost:3000` you will be greeted with the following page.

![Image of tileserver gl]()

## Display a map in your browser

Now that the vector tiles are available, we can move on to display a map in your browser.
The following HTML file defines a full-screen map using a custom Mapbox GL style.

<script src="https://gist.github.com/manuelroth/06380f112ff31a9b8f65b4971f1ee910.js"></script>

The `bright-v9.json` file defines how each feature of the map should be styled and where the assets like vector tiles, fonts and icons are stored.
Following you can see a simplified version of the style.
The vector tiles server we created before is now referenced as the source.

<script src="https://gist.github.com/manuelroth/d67f1ae67dddbb659ff17a7bb854096d.js"></script>

You can open the HTML file with your browser to checkout the webmap.

## Use our Public CDN for serving vector tiles

If you don't want to serve the vector tiles yourself, you can use our public CDN. Klokan Technologies provides a free and fast CDN serving vector tiles of the entire planet for development purposes and testing.

The free CDN service is not recommended for production use in mobile or web applications and commercial use is prohibited without permission. The service is made for demonstration of the open-source technology developed in this project and for designers, but should not be used on servers or in any final products.

### Using the Service

To use the public CDN instead of your local running server you need to replace the vector tile source in the style json with the url of the public CDN.

<script src="https://gist.github.com/manuelroth/427dbf552f69ebb997929148587deda4.js"></script>

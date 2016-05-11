---
layout: page
title: Getting Started
published: true
---

# Getting Started

In this tutorial you will learn how to serve vector tiles from an mbtiles file and how to display them in your browser. 

## Serve Vector Tiles

In order to render your map with Mapbox GL JS you need to set up a simple server which serves the vector tiles. The following script does exactly that it takes an mbtiles file and serves the containing vector tiles.

<script src="https://gist.github.com/manuelroth/8c03fe64bb2926e7f96e688c6bb1353c.js"></script>

An mbtiles file is essentialy just a sqlite database with a specific schema. The script listens on port 3000 and answers request in the form of `/<mbtiles-name>/<z>/<x>/<y>.pbf` and returns the vector tile at the requested xyz-coordinate.

We have prepared a repository containing all the necessary files for you. Simply clone [this repository](https://github.com/osm2vectortiles/mbtiles-server-example){:target="_blank"}, run `npm install`, [download](http://osm2vectortiles.org/downloads){:target="_blank"} your desired extract and run `node index.js` and the vector tiles are getting served.

## Display a map in your browser

Now that the vector tiles are getting served, we can move on to display a map in your browser. The following HTML file defines a full screen map using a custom map style.

<script src="https://gist.github.com/manuelroth/06380f112ff31a9b8f65b4971f1ee910.js"></script>

The `bright-v9.json` file defines how each feature of the map should be styled and where the assets like vector tiles, fonts and icons should come from. Following you can see a simplified version of the style. The vector tiles server we created before is referenced as the source for the vector tiles.

<script src="https://gist.github.com/manuelroth/d67f1ae67dddbb659ff17a7bb854096d.js"></script>

To get you started quickly we have created a repository with the necessary files and assets. Clone [this repository](https://github.com/osm2vectortiles/mapbox-gl-js-example){:target="_blank"}, start your favorite webserver(`npm install http-server -g) and you should see the map in your browser.

## Use our Public CDN for serving vector tiles

If you don't want to serve the vector tiles yourself, you can use our public CDN. Klokan Technologies provides a free and fast CDN serving vector tiles of the entire planet for development purposes and testing.

The free CDN service is not recommended for production use in mobile or web applications and commercial use is prohibited without permission. The service is made for demonstration of the open-source technology developed in this project and for designers, but should not be used on servers or in any final products.

### Using the Service

To use the public CDN instead of your local running server you need to replace the vector tile source in the style json with the url of the public CDN.

<script src="https://gist.github.com/manuelroth/427dbf552f69ebb997929148587deda4.js"></script>
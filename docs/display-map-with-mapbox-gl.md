---
layout: page
title: Display Map with Mapbox GL
published: true
---

## Display Map

To display a custom MapboxGL based map you can simply create a html file and
reference the public vector tile server of osm2vectortiles.

If you don't want to host the generated vector tiles from osm2vectortiles yourself you can use
our fast CDN serving PBF for free.

## 

All you need to serve a MapboxGL based map is the [Mapbox GL style JSON](https://www.mapbox.com/mapbox-gl-style-spec/) created
with [Mapbox Studio](https://www.mapbox.com/mapbox-studio/).
In this example we will serve the free OSM Bright style [provided by Mapbox](https://github.com/mapbox/mapbox-gl-styles).

The HTML file defines a fullscreen map and the CSS and JavaScript files required by Mapbox GL JS.
You can use your own JSON style but for the ease of getting started we will reference a JSON style that
we already uploaded at http://osm2vectortiles.org/styles/bright-v8.json.

A Mapbox API key is still required at this point to be able to download the fonts and glyphs from Mapbox.

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8' />
    <title></title>
    <meta name='viewport' content='initial-scale=1,maximum-scale=1,user-scalable=no' />
    <script src='https://api.tiles.mapbox.com/mapbox-gl-js/v0.12.1/mapbox-gl.js'></script>
    <link href='https://api.tiles.mapbox.com/mapbox-gl-js/v0.12.1/mapbox-gl.css' rel='stylesheet' />
    <style>
        body { margin:0; padding:0; }
        #map { position:absolute; top:0; bottom:0; width:100%; }
    </style>
</head>
<body>
<div id='map'></div>
<script>
mapboxgl.accessToken = 'pk.eyJ1IjoibW9yZ2Vua2FmZmVlIiwiYSI6IjIzcmN0NlkifQ.0LRTNgCc-envt9d5MzR75w';
var map = new mapboxgl.Map({
    container: 'map', // container id
    style: 'http://osm2vectortiles.org/styles/bright-v8.json', //stylesheet location
    center: [-74.50, 40], // starting position
    zoom: 9 // starting zoom
});
</script>

</body>
</html>
```

In difference to the original OSM Bright style JSON the path to the vector tile server has changed.
Instead of using Mapbox Streets we reference the vector tile server using the vector tiles from osm2vectortiles.

```javascript
"sources": {
    "mapbox": {
        "url": "http://vectortiles.osm2vectortiles.org/world.json",
        "type": "vector"
    }
},
```

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

The easiest way to get started is using the example repository we created.
Clone the repository and change into the directory.

```
git clone https://github.com/osm2vectortiles/mapbox-gl-js-example.git
```

## Files

In order for Mapbox GL JS to work you also need to provide the
[fonts](https://www.mapbox.com/mapbox-gl-style-spec/#glyphs) and
[sprites](https://www.mapbox.com/mapbox-gl-style-spec/#sprite).
These resources are contained in the folder `assets`.

The [Mapbox GL Style JSON](https://www.mapbox.com/mapbox-gl-style-spec/) of OSM Bright is located at `bright-v8.json`.
You can create your own styles with Mapbox Studio.

If you want to serve the Mapbox GL Style JSON without Mapbox you need to configure three URLs.
1. Change the `sources` URL to the free osm2vectortile serve or use your own server
2. Change the `sprite` URL to the location of your sprites
3. Change the `glyphs` URL to the location of your fonts

```javascript
"sources": {
    "mapbox": {
        "url": "http://vectortiles.osm2vectortiles.org/world.json",
        "type": "vector"
    }
},
"sprite": "/assets/sprite",
"glyphs": "/assets/font/{fontstack}/{range}.pbf"
```


All you need to serve a MapboxGL based map is the [Mapbox GL style JSON](https://www.mapbox.com/mapbox-gl-style-spec/) created
with [Mapbox Studio](https://www.mapbox.com/mapbox-studio/).
In this example we will serve the free OSM Bright style [provided by Mapbox](https://github.com/mapbox/mapbox-gl-styles).

The HTML file defines a fullscreen map and the CSS and JavaScript files required by Mapbox GL JS.
You can use your own JSON style but for the ease of getting started we will reference a JSON style that
we already uploaded at http://osm2vectortiles.org/styles/bright-v8.json.

Because we use the local sprites and fonts we don't need a Mapbox API key.

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8' />
    <title>MapBox GL JS with osm2vectortiles Example</title>
    <meta name='viewport' content='initial-scale=1,maximum-scale=1,user-scalable=no' />
    <script src='//api.tiles.mapbox.com/mapbox-gl-js/v0.10.0/mapbox-gl.js'></script>
    <link href='//api.tiles.mapbox.com/mapbox-gl-js/v0.10.0/mapbox-gl.css' rel='stylesheet' />
    <style>
        body { margin:0; padding:0; }
        #map { position:absolute; top:0; bottom:0; width:100%; }
    </style>
</head>
<body>

<div id='map'></div>
<script>
mapboxgl.accessToken = 'NOT-REQUIRED-WITH-YOUR-VECTOR-TILES-DATA';

var map = new mapboxgl.Map({
    container: 'map',
    style: '/bright-v8.json',
    center: [8.3221, 46.5928],
    zoom: 1,
    hash: true
});
map.addControl(new mapboxgl.Navigation());
</script>
</body>
</html>
```

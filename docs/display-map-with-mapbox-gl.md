---
layout: page
title: Display Map with Mapbox GL
published: true
---

# Display Map with Mapbox GL

To display a custom Mapbox GL based map you need to create a HTML file and
reference [the public vector tile CDN](/docs/use-public-cdn/).
You are free to download and
host the vector tiles yourself but we provide a fast and distributed CDN service for serving
the PBFs for you.

## Clone example Repository

The easiest way to get started is using the `mapbox-gl-js-exmaple` repository.
Clone the repository and change into the directory.

```
git clone https://github.com/osm2vectortiles/mapbox-gl-js-example.git
```

## Configure Source, Fonts and Sprites

In order for Mapbox GL JS to work you also need to provide the
[fonts](https://www.mapbox.com/mapbox-gl-style-spec/#glyphs) and
[sprites](https://www.mapbox.com/mapbox-gl-style-spec/#sprite).
These resources are contained in the folder `assets`.

The [Mapbox GL Style JSON](https://www.mapbox.com/mapbox-gl-style-spec/) of OSM Bright is located at `bright-v8.json`.
You can create your own styles with Mapbox Studio.

If you want to serve the Mapbox GL Style JSON without Mapbox you need to configure three URLs.

1. Change the `sources` URL to the free CDN server or use your own server
2. Change the `sprite` URL to the location of your sprites
3. Change the `glyphs` URL to the location of your fonts

```javascript
"sources": {
    "mapbox": {
        "url": "http://osm2vectortiles.tileserver.com/v1.json",
        "type": "vector"
    }
},
"sprite": "/assets/sprite",
"glyphs": "/assets/font/{fontstack}/{range}.pbf"
```

## Initialize the Map

In order to serve a MapboxGL based map you need a [Mapbox GL style JSON](https://www.mapbox.com/mapbox-gl-style-spec/) created with [Mapbox Studio](https://www.mapbox.com/mapbox-studio/).
In this example we will serve the free OSM Bright style [provided by Mapbox](https://github.com/mapbox/mapbox-gl-styles).

The HTML file defines a full screen map and the CSS and JavaScript files required by Mapbox GL JS.
The `bright-v8.json` style is loaded from the local directory.

Because we use the local sprites and fonts we don't need a Mapbox API key.

{% highlight html %}
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
{% endhighlight %}

## Serve the Map

You need a simple HTTP server for serving the HTML and assets.

If you have Python installed you can run `python -m SimpleHTTPServer` 
in the working directory and visit the map at `localhost:8000`.

If you have NodeJS installed you can install a simple http server with `npm install http-server -g`
and run it in the working directory with `http-server` and visit the map at `localhost:8080`.

Or if you are using Docker you can run a container serving the static files at `localhost:8000`
with `docker run --rm -v $(pwd):/usr/share/nginx/html:ro -p 8000:80 nginx`.

It is even possible to host the map on GitHub Pages.

---
layout: page
title: Collection of Map
published: true
---

## Vector Maps


### OSM Bright

<div class="map-preview" id="vector-osm-bright-map"></div>

### Basic

<div class="map-preview" id="vector-basic-map"></div>

<script>
mapboxgl.accessToken = 'pk.eyJ1IjoibW9yZ2Vua2FmZmVlIiwiYSI6IjIzcmN0NlkifQ.0LRTNgCc-envt9d5MzR75w';
var brightMap = new mapboxgl.Map({
    container: 'vector-osm-bright-map',
    style: '/styles/bright-v8.json',
    center: [8.54124, 47.36686],
    zoom: 6
});
var basicMap = new mapboxgl.Map({
    container: 'vector-basic-map',
    style: '/styles/basic-v8.json',
    center: [8.54124, 47.36686],
    zoom: 6
});
</script>

## Raster Maps

### OSM Bright

<div class="map-preview" id="osm-bright-map"></div>

### Streets Basic

<div class="map-preview" id="streets-basic-map"></div>

### Woodcut

<div class="map-preview" id="woodcut-map"></div>

### Comic

<div class="map-preview" id="comic-map"></div>

### Pirates

<div class="map-preview" id="pirates-map"></div>

### Light

<div class="map-preview" id="light-map"></div>

### Dark

<div class="map-preview" id="dark-map"></div>

### Wheatpaste

<div class="map-preview" id="wheatpaste-map"></div>

### 14th Street

<div class="map-preview" id="14th-street-map"></div>

<script>
var comicMap = L.mapbox.map('comic-map', 'http://rastertiles.osm2vectortiles.org/comic/index.json').setView([47.3739, 8.5456], 13);
var brightMap = L.mapbox.map('osm-bright-map', 'http://rastertiles.osm2vectortiles.org/osm-bright/index.json').setView([53.390, 1.351], 6);
var lightMap= L.mapbox.map('light-map', 'http://rastertiles.osm2vectortiles.org/light/index.json').setView([48.8403, 2.4651], 10);
var darkMap= L.mapbox.map('dark-map', 'http://rastertiles.osm2vectortiles.org/dark/index.json').setView([37.6575, -122.2754], 11);
var streetsBasicMap= L.mapbox.map('streets-basic-map', 'http://rastertiles.osm2vectortiles.org/streets-basic/index.json').setView([42.59, -93.65], 4);
var woodcutMap = L.mapbox.map('woodcut-map', 'http://rastertiles.osm2vectortiles.org/woodcut/index.json').setView([42.956, 11.667], 5);
var piratesMap = L.mapbox.map('pirates-map', 'http://rastertiles.osm2vectortiles.org/pirates/index.json').setView([15.401, -76.498], 6);
var fourteenStreetMap= L.mapbox.map('14th-street-map', 'http://rastertiles.osm2vectortiles.org/14th-street/index.json').setView([46.9493, 7.4492], 15);
var wheatpasteMap = L.mapbox.map('wheatpaste-map', 'http://rastertiles.osm2vectortiles.org/wheatpaste/index.json').setView([41.8875, 12.4753], 11);
</script>


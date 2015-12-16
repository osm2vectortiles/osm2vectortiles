---
layout: page
title: Collection of Map
published: true
---

## Vector Maps

<div id="vector-map" class="map-preview"></div>

<button id="vector-osm-bright">OSM Bright</button>
<button id="vector-osm-basic">Basic Map</button>

<script src='https://api.tiles.mapbox.com/mapbox-gl-js/v0.12.1/mapbox-gl.js'></script>
<link href='https://api.tiles.mapbox.com/mapbox-gl-js/v0.12.1/mapbox-gl.css' rel='stylesheet' />

<script>
	mapboxgl.accessToken = 'pk.eyJ1IjoibW9yZ2Vua2FmZmVlIiwiYSI6IjIzcmN0NlkifQ.0LRTNgCc-envt9d5MzR75w';
	var brightMap = new mapboxgl.Map({
		    container: 'vector-map',
		    style: '/styles/bright-v8.json',
		    center: [8.54124, 47.36686],
		    zoom: 6
	});

	var bright = document.getElementById("vector-osm-bright");
	bright.onclick = function(e) {
		e.preventDefault();
        e.stopPropagation();
        var brightMap = new mapboxgl.Map({
		    container: 'vector-map',
		    style: '/styles/bright-v8.json',
		    center: [8.54124, 47.36686],
		    zoom: 6
		});
	}
	var basic = document.getElementById("vector-osm-basic");
	basic.onclick = function(e) {
		e.preventDefault();
        e.stopPropagation();
        var basicMap = new mapboxgl.Map({
		    container: 'vector-map',
		    style: '/styles/basic-v8.json',
		    center: [8.54124, 47.36686],
		    zoom: 6
		});
	}
</script>

## Raster Maps

<div id="raster-map" class="map-preview"></div>

<button id="raster-osm-bright">OSM Bright</button>
<button id="comic-map">Comic Map</button>
<button id="light-map">Light Map</button>
<button id="dark-map">Dark Map</button>
<button id="streets-basic">Streets Basic</button>
<button id="woodcut">Woodcut</button>
<button id="pirates">Pirates</button>
<button id="fourteen-street">14th Street</button>
<button id="wheatpaste">Wheatpaste</button>

<script src="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.js"></script>
<link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.css" />

<script>
var map = L.map('raster-map').setView([51.505, -0.09], 13);
var layer = L.tileLayer('http://rastertiles.osm2vectortiles.org/osm-bright/{z}/{x}/{y}.png').addTo(map);

var osm_bright = document.getElementById("raster-osm-bright");
var comic_map = document.getElementById("comic-map");
var light_map = document.getElementById("light-map");
var dark_map = document.getElementById("dark-map");
var streets_basic = document.getElementById("streets-basic");
var woodcut = document.getElementById("woodcut");
var pirates = document.getElementById("pirates");
var fourteen_street = document.getElementById("fourteen-street");
var wheatpaste = document.getElementById("wheatpaste");

addClickListener(osm_bright, 'http://rastertiles.osm2vectortiles.org/osm-bright/{z}/{x}/{y}.png');
addClickListener(comic_map, 'http://rastertiles.osm2vectortiles.org/comic/{z}/{x}/{y}.png');
addClickListener(light_map, 'http://rastertiles.osm2vectortiles.org/light/{z}/{x}/{y}.png');
addClickListener(dark_map, 'http://rastertiles.osm2vectortiles.org/dark/{z}/{x}/{y}.png');
addClickListener(streets_basic, 'http://rastertiles.osm2vectortiles.org/streets-basic/{z}/{x}/{y}.png');
addClickListener(woodcut, 'http://rastertiles.osm2vectortiles.org/woodcut/{z}/{x}/{y}.png');
addClickListener(pirates, 'http://rastertiles.osm2vectortiles.org/pirates/{z}/{x}/{y}.png');
addClickListener(fourteen_street, 'http://rastertiles.osm2vectortiles.org/14th-street/{z}/{x}/{y}.png');
addClickListener(wheatpaste, 'http://rastertiles.osm2vectortiles.org/wheatpaste/{z}/{x}/{y}.png');

function addClickListener(mapButton, url) {
	mapButton.onclick = function(e) {
		e.preventDefault();
	    e.stopPropagation();
	    layer.setUrl(url);
	}
}
</script>

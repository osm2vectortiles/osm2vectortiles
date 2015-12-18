---
layout: page
title: Collection of Map
published: true
---

## Vector Maps

<div id="vector-map" class="map-preview"></div>

<div id="map-container">
	<button id="vector-osm-bright" class="map-button">OSM Bright</button
	><button id="vector-osm-basic" class="map-button">Basic Map</button>
</div>
</br>
<div id="vector-style-reference"></div>

<script src='https://api.tiles.mapbox.com/mapbox-gl-js/v0.12.1/mapbox-gl.js'></script>
<link href='https://api.tiles.mapbox.com/mapbox-gl-js/v0.12.1/mapbox-gl.css' rel='stylesheet' />

<script>
	var vectorStyleReference = document.getElementById("vector-style-reference");
	vectorStyleReference.innerHTML = 'The map above uses the following style project: <a href="https://github.com/mapbox/mapbox-gl-styles/blob/master/styles/bright-v8.json">OSM Bright</a>';
	mapboxgl.accessToken = 'pk.eyJ1IjoibW9yZ2Vua2FmZmVlIiwiYSI6IjIzcmN0NlkifQ.0LRTNgCc-envt9d5MzR75w';
	var vectorMap = new mapboxgl.Map({
		    container: 'vector-map',
		    style: '/styles/bright-v8.json',
		    center: [8.5456, 47.3739],
		    zoom: 11
	}).addControl(new mapboxgl.Navigation({position: 'top-left'}));

	var bright = document.getElementById("vector-osm-bright");
	bright.onclick = function(e) {
		e.preventDefault();
        e.stopPropagation();
        vectorMap.setStyle('/styles/bright-v8.json');
		vectorStyleReference.innerHTML = 'The map above uses the following style project: <a href="https://github.com/mapbox/mapbox-gl-styles/blob/master/styles/bright-v8.json">OSM Bright</a>';

	}
	var basic = document.getElementById("vector-osm-basic");
	basic.onclick = function(e) {
		e.preventDefault();
        e.stopPropagation();
        vectorMap.setStyle('/styles/basic-v8.json');
		vectorStyleReference.innerHTML = 'The map above uses the following style project: <a href="https://github.com/mapbox/mapbox-gl-styles/blob/master/styles/basic-v8.json">Basic Map</a>';
	}
</script>

## Raster Maps

<div id="raster-map" class="map-preview"></div>
<div id="map-container">
	<button id="raster-osm-bright" class="map-button">OSM Bright</button
	><button id="retro" class="map-button">Retro</button
    ><button id="comic-map" class="map-button">Comic Map</button
	><button id="light-map" class="map-button">Light Map</button
	><button id="dark-map" class="map-button">Dark Map</button
	><button id="streets-basic" class="map-button">Streets Basic</button
	><button id="woodcut" class="map-button">Woodcut</button><button id="pirates" class="map-button">Pirates</button
	><button id="wheatpaste" class="map-button">Wheatpaste</button>
</div>
</br>
<div id="raster-style-reference"></div>

<script src="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.js"></script>
<link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.css" />

<script>
var map = L.map('raster-map').setView([47.3739, 8.5456], 13);
var layer = L.tileLayer('http://klokantech-{s}.tileserver.com/osm-bright/{z}/{x}/{y}.png?key=WQ5sRntXphOrWgesmtmU', 
	{
		id: 'MapID', 
		attribution: '© <a href="http://www.openstreetmap.org/copyright">OpenStreetMap contributors</a>',
		subdomains: '0123'
	}
).addTo(map);

addClickListener('raster-osm-bright', 'http://klokantech-{s}.tileserver.com/osm-bright/{z}/{x}/{y}.png?key=WQ5sRntXphOrWgesmtmU', 'https://github.com/mapbox/mapbox-studio-osm-bright.tm2');
addClickListener('comic-map', 'http://rastertiles.osm2vectortiles.org/comic/{z}/{x}/{y}.png', 'https://github.com/mapbox/mapbox-studio-comic.tm2');
addClickListener('light-map', 'http://rastertiles.osm2vectortiles.org/light/{z}/{x}/{y}.png', 'https://github.com/mapbox/mapbox-studio-light.tm2');
addClickListener('dark-map', 'http://rastertiles.osm2vectortiles.org/dark/{z}/{x}/{y}.png', 'https://github.com/mapbox/mapbox-studio-dark.tm2');
addClickListener('streets-basic', 'http://klokantech-{s}.tileserver.com/streets-basic/{z}/{x}/{y}.png?key=WQ5sRntXphOrWgesmtmU', 'https://github.com/mapbox/mapbox-studio-streets-basic.tm2');
addClickListener('woodcut', 'http://rastertiles.osm2vectortiles.org/woodcut/{z}/{x}/{y}.png', 'https://github.com/mapbox/mapbox-studio-woodcut.tm2');
addClickListener('pirates', 'http://rastertiles.osm2vectortiles.org/pirates/{z}/{x}/{y}.png', 'https://github.com/mapbox/mapbox-studio-pirates.tm2');
addClickListener('wheatpaste', 'http://rastertiles.osm2vectortiles.org/wheatpaste/{z}/{x}/{y}.png', 'https://github.com/mapbox/mapbox-studio-wheatpaste.tm2');
addClickListener('retro', 'http://klokantech-{s}.tileserver.com/retro/{z}/{x}/{y}.png?key=WQ5sRntXphOrWgesmtmU');

var rasterStyleReference = document.getElementById("raster-style-reference");
rasterStyleReference.innerHTML = 'The map above uses the following style project: <a href="https://github.com/mapbox/mapbox-studio-osm-bright.tm2">OSM Bright</a>';

function addClickListener(name, url, styleRefString) {
	var mapButton = document.getElementById(name);
	var styleName = document.getElementById(name).innerHTML;
	mapButton.onclick = function(e) {
		e.preventDefault();
	    e.stopPropagation();
	    layer.setUrl(url);
	    if(name === 'retro') {
	    	rasterStyleReference.innerHTML = 'The map above uses a custom style project of <a href="http://www.klokantech.com/">Klokan Technologies</a>.'
	    } else {
	    	rasterStyleReference.innerHTML = 'The map above uses the following style project: ' + '<a href=' + styleRefString + '>' + styleName + '</a>';
	    }
	}
}
</script>

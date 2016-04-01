---
layout: page
title: Bookmarks
published: true
---

# Location Bookmarks

A collection of global feature bookmarks
for visually examining osm2vectortiles.

<script src='https://api.tiles.mapbox.com/mapbox-gl-js/v0.15.0/mapbox-gl.js'></script>
<link href='https://api.tiles.mapbox.com/mapbox-gl-js/v0.15.0/mapbox-gl.css' rel='stylesheet' />

## Airports

### Zurich Airport

<div class="map-preview" data-lat="47.4582802" data-lon="8.548178" data-zoom="13"></div>

### London Heathrow

<div class="map-preview" data-lat="51.4707" data-lon="-0.4579" data-zoom="13"></div>

### Munich International Airport

<div class="map-preview" data-lat="48.3535" data-lon="11.7918" data-zoom="13"></div>

<script>
	mapboxgl.accessToken = 'pk.eyJ1IjoibW9yZ2Vua2FmZmVlIiwiYSI6IjIzcmN0NlkifQ.0LRTNgCc-envt9d5MzR75w';

	var divs = document.querySelectorAll('.map-preview');

	[].forEach.call(divs, function(div) {
		var lat = parseFloat(div.getAttribute("data-lat"));
		var lon = parseFloat(div.getAttribute("data-lon"));
		var zoom = parseFloat(div.getAttribute("data-zoom"));
		var vectorMap = new mapboxgl.Map({
		    container: div,
		    style: '/styles/bright-v8.json',
		    center: [lon, lat],
		    zoom: zoom
		});
	});
</script>

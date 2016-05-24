---
layout: page
title: Bookmarks
published: true
---

# Location Bookmarks

A collection of global feature bookmarks
for visually examining osm2vectortiles.

<script src='https://api.tiles.mapbox.com/mapbox-gl-js/v0.18.0/mapbox-gl.js'></script>
<link href='https://api.tiles.mapbox.com/mapbox-gl-js/v0.18.0/mapbox-gl.css' rel='stylesheet' />

## Cities

### Zurich

<div class="map-preview" data-lat="47.3782" data-lon="8.5395" data-zoom="11"></div>

### London

<div class="map-preview" data-lat="51.5071" data-lon="-0.1266" data-zoom="11"></div>

### Paris

<div class="map-preview" data-lat="48.85618" data-lon="2.35214" data-zoom="11"></div>

### New York

<div class="map-preview" data-lat="40.7306" data-lon="-73.9860" data-zoom="11"></div>

### Rome

<div class="map-preview" data-lat="41.89346" data-lon="12.48273" data-zoom="11"></div>

## Airports

### Zurich Airport

<div class="map-preview" data-lat="47.4582802" data-lon="8.548178" data-zoom="13"></div>

### London Heathrow

<div class="map-preview" data-lat="51.4707" data-lon="-0.4579" data-zoom="13"></div>

### Munich International Airport

<div class="map-preview" data-lat="48.3535" data-lon="11.7918" data-zoom="13"></div>

<script>
	var divs = document.querySelectorAll('.map-preview');

	[].forEach.call(divs, function(div) {
		var lat = parseFloat(div.getAttribute("data-lat"));
		var lon = parseFloat(div.getAttribute("data-lon"));
		var zoom = parseFloat(div.getAttribute("data-zoom"));
		var vectorMap = new mapboxgl.Map({
		    container: div,
		    style: 'https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-styles/master/styles/bright-v9-cdn.json',
		    center: [lon, lat],
		    zoom: zoom
		});
	});
</script>

---
layout: page
title: Collection of Map
published: true
---

<div id="vector-map" class="map-preview"></div>

<div id="map-container">
	<button id="vector-osm-bright" class="map-button">OSM Bright</button
	><button id="vector-osm-basic" class="map-button">Basic Map</button>
</div>
<br />
<div id="vector-style-reference"></div>

<script src='https://api.tiles.mapbox.com/mapbox-gl-js/v0.18.0/mapbox-gl.js'></script>
<link href='https://api.tiles.mapbox.com/mapbox-gl-js/v0.18.0/mapbox-gl.css' rel='stylesheet' />

<script>
	var vectorStyleReference = document.getElementById("vector-style-reference");
	vectorStyleReference.innerHTML = 'The map above uses the following style project: <a href="https://github.com/mapbox/mapbox-gl-styles/blob/master/styles/bright-v8.json">OSM Bright</a>';
	mapboxgl.accessToken = 'pk.eyJ1IjoibW9yZ2Vua2FmZmVlIiwiYSI6IjIzcmN0NlkifQ.0LRTNgCc-envt9d5MzR75w';

	if (!mapboxgl.supported()) {
		var vectorMapContainer = document.getElementById("vector-map");
		vectorMapContainer.innerHTML = 'Your browser does not support Mapbox GL. Either your browser does not support WebGL or it is disabled, please check <a href="https://get.webgl.org/">http://get.webgl.org</a> for more information.'
	} else {
		var vectorMap = new mapboxgl.Map({
		    container: 'vector-map',
		    style: '/styles/bright-v8.json',
		    center: [8.5456, 47.3739],
		    zoom: 11
		}).addControl(new mapboxgl.Navigation({position: 'top-left'}));
	}

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

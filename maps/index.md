---
layout: page
title: Collection of Map
published: true
---

<div id="vector-style-reference"></div>
<br />
<div id="map-container">
	<button id="vector-bright" class="map-button">Bright</button
	><button id="vector-basic" class="map-button">Basic</button
	><button id="vector-streets" class="map-button">Streets</button>
</div>
<div id="vector-map" class="map-preview"></div>
<script src='https://api.tiles.mapbox.com/mapbox-gl-js/v0.18.0/mapbox-gl.js'></script>
<link href='https://api.tiles.mapbox.com/mapbox-gl-js/v0.18.0/mapbox-gl.css' rel='stylesheet' />
<script>
	var vectorStyleReference = document.getElementById("vector-style-reference");
	vectorStyleReference.innerHTML = 'The map below uses the following style project: <a href="https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-js-example/master/bright-v9.json" target="_blank">Bright</a>';
	if (!mapboxgl.supported()) {
		var vectorMapContainer = document.getElementById("vector-map");
		vectorMapContainer.innerHTML = 'Your browser does not support Mapbox GL. Either your browser does not support WebGL or it is disabled, please check <a href="https://get.webgl.org/">http://get.webgl.org</a> for more information.'
	} else {
		var vectorMap = new mapboxgl.Map({
		    container: 'vector-map',
		    style: 'https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-js-example/master/bright-v9.json',
		    center: [8.5456, 47.3739],
		    zoom: 11
		}).addControl(new mapboxgl.Navigation());
		vectorMap.scrollZoom.disable();
	}

	var bright = document.getElementById("vector-bright");
	bright.onclick = function(e) {
		e.preventDefault();
        e.stopPropagation();
        vectorMap.setStyle('https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-js-example/master/bright-v9.json');
		vectorStyleReference.innerHTML = 'The map above uses the following style project: <a href="https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-js-example/master/bright-v9.json" target="_blank">Bright</a>';
		document.querySelector("#bright").style.display = "block";
		document.querySelector("#basic").style.display = "none";
		document.querySelector("#streets").style.display = "none";
	}
	var basic = document.getElementById("vector-basic");
	basic.onclick = function(e) {
		e.preventDefault();
        e.stopPropagation();
        vectorMap.setStyle('https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-js-example/master/basic-v9.json');
		vectorStyleReference.innerHTML = 'The map above uses the following style project: <a href="https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-js-example/master/basic-v9.json" target="_blank">Basic</a>';
		document.querySelector("#bright").style.display = "none";
		document.querySelector("#basic").style.display = "block";
		document.querySelector("#streets").style.display = "none";
	}
	var streets = document.getElementById("vector-streets");
	streets.onclick = function(e) {
		e.preventDefault();
        e.stopPropagation();
        vectorMap.setStyle('https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-js-example/master/streets-v9.json');
		vectorStyleReference.innerHTML = 'The map above uses the following style project: <a href="https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-js-example/master/streets-v9.json" target="_blank">Streets</a>';
		document.querySelector("#bright").style.display = "none";
		document.querySelector("#basic").style.display = "none";
		document.querySelector("#streets").style.display = "block";
	}
</script>
<div>
	<div id="bright">
		<script src="https://gist.github.com/manuelroth/33e471c9ecd4977dee6bf4839ff9488a.js"></script>
	</div>
	<div id="basic">
		<script src="https://gist.github.com/manuelroth/2a20607d02b71b29d02a1963a7e12e6e.js"></script>
	</div>
	<div id="streets">
		<script src="https://gist.github.com/manuelroth/d0e37ef2e8f8e7080317c779044979d7.js"></script>
	</div>
</div>

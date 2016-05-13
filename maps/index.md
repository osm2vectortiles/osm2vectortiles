---
layout: page
title: Collection of Map
published: true
---

<div>Choose between the following map styles, copy the html code below the map and display it in your browser.
</div>

<br />
<div id="map-container">
	<button id="vector-bright" class="map-button">Bright</button
	><button id="vector-basic" class="map-button">Basic</button
	><button id="vector-streets" class="map-button">Streets</button
	><button id="vector-dark" class="map-button">Dark</button
	><button id="vector-light" class="map-button">Light</button>
</div>
<div id="vector-map" class="map-preview"></div>
<script src='https://api.tiles.mapbox.com/mapbox-gl-js/v0.18.0/mapbox-gl.js'></script>
<link href='https://api.tiles.mapbox.com/mapbox-gl-js/v0.18.0/mapbox-gl.css' rel='stylesheet' />
<script>
	if (!mapboxgl.supported()) {
		var vectorMapContainer = document.getElementById("vector-map");
		vectorMapContainer.innerHTML = 'Your browser does not support Mapbox GL. Either your browser does not support WebGL or it is disabled, please check <a href="https://get.webgl.org/">http://get.webgl.org</a> for more information.'
	} else {
		var vectorMap = new mapboxgl.Map({
		    container: 'vector-map',
		    style: 'https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-styles/master/styles/bright-v9-cdn.json',
		    center: [8.5456, 47.3739],
		    zoom: 11
		}).addControl(new mapboxgl.Navigation());
		vectorMap.scrollZoom.disable();
		var selectedStyle = 0;
	}

	var bright = document.getElementById("vector-bright");
	bright.onclick = function(e) {
		e.preventDefault();
        e.stopPropagation();
        vectorMap.setStyle('https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-styles/master/styles/bright-v9-cdn.json');
		document.querySelector("#bright").style.display = "block";
		document.querySelector("#basic").style.display = "none";
		document.querySelector("#streets").style.display = "none";
		document.querySelector("#dark").style.display = "none";
		document.querySelector("#light").style.display = "none";
		selectedStyle = 0;
	}
	var basic = document.getElementById("vector-basic");
	basic.onclick = function(e) {
		e.preventDefault();
        e.stopPropagation();
        vectorMap.setStyle('https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-styles/master/styles/basic-v9-cdn.json');
		document.querySelector("#bright").style.display = "none";
		document.querySelector("#basic").style.display = "block";
		document.querySelector("#streets").style.display = "none";
		document.querySelector("#dark").style.display = "none";
		document.querySelector("#light").style.display = "none";
		selectedStyle = 1;
	}
	var streets = document.getElementById("vector-streets");
	streets.onclick = function(e) {
		e.preventDefault();
        e.stopPropagation();
        vectorMap.setStyle('https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-styles/master/styles/streets-v9-cdn.json');
		document.querySelector("#bright").style.display = "none";
		document.querySelector("#basic").style.display = "none";
		document.querySelector("#streets").style.display = "block";
		document.querySelector("#dark").style.display = "none";
		document.querySelector("#light").style.display = "none";
		selectedStyle = 2;
	}
	var dark = document.getElementById("vector-dark");
	dark.onclick = function(e) {
		e.preventDefault();
        e.stopPropagation();
        vectorMap.setStyle('https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-styles/master/styles/dark-v9-cdn.json');
		document.querySelector("#bright").style.display = "none";
		document.querySelector("#basic").style.display = "none";
		document.querySelector("#streets").style.display = "none";
		document.querySelector("#dark").style.display = "block";
		document.querySelector("#light").style.display = "none";
		selectedStyle = 3;
	}
	var light = document.getElementById("vector-light");
	light.onclick = function(e) {
		e.preventDefault();
        e.stopPropagation();
        vectorMap.setStyle('https://raw.githubusercontent.com/osm2vectortiles/mapbox-gl-styles/master/styles/light-v9-cdn.json');
		document.querySelector("#bright").style.display = "none";
		document.querySelector("#basic").style.display = "none";
		document.querySelector("#streets").style.display = "none";
		document.querySelector("#dark").style.display = "none";
		document.querySelector("#light").style.display = "block";
		selectedStyle = 4;
	}
	// instantiate map clipboard
	  new Clipboard('.map-clipboard-button', {
	    text: function(trigger) {
	        return document.getElementsByClassName("gist-data")[selectedStyle].innerText;
	    }
	});
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
	<div id="dark">
		<script src="https://gist.github.com/manuelroth/80cb27ff4eecd822661baf3abeab6150.js"></script>
	</div>
	<div id="light">
		<script src="https://gist.github.com/manuelroth/fdb546e2abf91ec1b3b3f9b7b253aec3.js"></script>
	</div>
</div>
<div id="map-clipboard">
	<button class="map-clipboard-button">
	    <img src="/img/clipboard-white.svg" class="map-clipboard-img" alt="Copy to clipboard">
	    <div>Copy example</div>
	</button>
</div>

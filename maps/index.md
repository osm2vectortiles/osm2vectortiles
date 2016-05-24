---
layout: page
title: Map Styles
published: true
---

<div id="map-text">
	<p>
		Choose between the following map styles, copy the html code below the map and display it in your browser.
	</p>
	<li style="list-style-type: square">
		Need any help? <a href="/docs">Check out the documentation</a>
	</li>
</div>

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
	<button class="map-clipboard-button" onclick="showCopiedHint()">
		<span id="map-clipboard-text" class="map-clipboard-img">Copy example</spam>
	</button>
</div>

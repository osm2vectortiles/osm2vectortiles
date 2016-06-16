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
	><button id="vector-basic" class="map-button">Basic</button>
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
</div>
<div id="map-clipboard">
	<button class="map-clipboard-button" onclick="showCopiedHint()">
		<span id="map-clipboard-text" class="map-clipboard-img">Copy example</span>
	</button>
</div>
<div class="container">
  <div class="row pady-2">
      <p>
      The <a href="https://github.com/osm2vectortiles/mapbox-gl-styles">example styles</a> are derived from <a href="https://github.com/mapbox/mapbox-gl-styles">Mapbox Open Styles</a> and are copyright (c) 2014, Mapbox, all rights reserved.
      </p>
  </div>
</div>

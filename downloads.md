---
layout: page
title: Downloads
published: true
---

# Downloads

You can download the entire planet, country or even city extracts. All the extracts contain some world data on lower zoom levels. This lets your map look great without having to download the entire planet. We want you to use our vector tiles to build great stuff. Therefore the vector tiles are under
the [Open Database License](https://tldrlegal.com/license/odc-open-database-license-(odbl)) the same license [OpenStreetMap is using](https://www.openstreetmap.org/copyright).

<ul>
  <li>
    <strong>OpenStreetMap data in the full planet and extract last updated on <span id="timestamp"></span></strong>
  </li>
  <li>The <a href="https://github.com/osm2vectortiles/osm2vectortiles/releases/latest">OSM2VectorTiles v2 tiles</a> are meant for use with Mapbox GL JSON styles and Mapbox GL.<br/>
  The no longer maintained <a href="https://github.com/osm2vectortiles/osm2vectortiles/releases/tag/v1.0">OSM2VectorTiles v1 tiles</a> (for use with CartoCSS and Mapnik) are available at <a href="/downloads-v1/">Downloads v1</a>.
  </li>
  <li>
    Need any help? <a href="/docs/">Check out the documentation</a>
  </li>
  <li>
    Don’t see your country or city listed below? Contribute by submitting a pull request on our list of <a href="https://github.com/osm2vectortiles/osm2vectortiles/blob/master/src/create-extracts/country_extracts.tsv" target="_blank">countries</a> or <a href="https://github.com/osm2vectortiles/osm2vectortiles/blob/master/src/create-extracts/city_extracts.tsv" target="_blank">cities</a>, or <a href="https://github.com/osm2vectortiles/osm2vectortiles/issues/new" target="_blank">just ask by opening a new issue</a>.
  </li>
</ul>

<div class="row">
  <div class="col12">
	  <div id="planet-nav" class="col4 download-section" onclick="showSection('planet')">
	    <div class="download-section-circle" style="background-image: url(/img/planet.png)"></div>
	    <h2>Planet</h2>
	  </div>
	  <div id="country-nav" class="col4 download-section" onclick="showSection('country')">
	  	<div class="download-section-circle" style="background-image: url(/img/country.png);"></div>
	    <h2>Country</h2>
	  </div>
	  <div id="city-nav" class="col4 download-section" onclick="showSection('city')">
	  	<div class="download-section-circle" style="background-image: url(/img/city.png)"></div>
	    <h2>City</h2>
	  </div>
	</div>
</div>

<div id="planet-list">
	<div class="col12 download-item">
		<div class="col4 download-title" onclick="location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v2.0/planet_2016-06-20_3d4cb571d3d0d828d230aac185281e97_z0-z14.mbtiles'">
			Full Planet <br/><small>MD5: <span id="md5sum"></span></small>
		</div>
		<div class="col2" onclick="location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v2.0/planet_2016-06-20_3d4cb571d3d0d828d230aac185281e97_z0-z14.mbtiles'">
			54 GB
		</div>
		<div class="col6 clipboard">
			<input id="world" class="clipboard-input" value="https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v2.0/planet_2016-06-20_3d4cb571d3d0d828d230aac185281e97_z0-z14.mbtiles">
			<button class="clipboard-button hint--bottom hint--rounded" data-clipboard-target="#world" onclick="setHint(this, 'Copied!')" onmouseout="setHint(this, 'Copy to clipboard')">
			    <img src="/img/clipboard-black.svg" class="clipboard-img" alt="Copy to clipboard">
			</button>
		</div>
	</div>
	<div class="col12 download-item">
		<div class="col4 download-title" onclick="location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v2.0/planet_2016-06-20_7088ce06a738dcb3104c769adc11ac2c_z0-z8.mbtiles'">
			Planet from zoom level 0 to 8
		</div>
		<div class="col2" onclick="location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v2.0/planet_2016-06-20_7088ce06a738dcb3104c769adc11ac2c_z0-z8.mbtiles'">
			261 MB
		</div>
		<div class="col6 clipboard">
			<input id="world_z0-z8" class="clipboard-input" value="https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v2.0/planet_2016-06-20_7088ce06a738dcb3104c769adc11ac2c_z0-z8.mbtiles">
			<button class="clipboard-button hint--bottom hint--rounded" data-clipboard-target="#world_z0-z8" onclick="setHint(this, 'Copied!')" onmouseout="setHint(this, 'Copy to clipboard')">
			    <img src="/img/clipboard-black.svg" class="clipboard-img" alt="Copy to clipboard">
			</button>
		</div>
	</div>
	<div class="col12 download-item">
		<div class="col4 download-title" onclick="location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v2.0/planet_2016-06-20_7088ce06a738dcb3104c769adc11ac2c_z0-z5.mbtiles'">
			Planet from zoom level 0 to 5
		</div>
		<div class="col2" onclick="location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v2.0/planet_2016-06-20_7088ce06a738dcb3104c769adc11ac2c_z0-z5.mbtiles'">
			10 MB
		</div>
		<div class="col6 clipboard">
			<input id="world_z0-z5" class="clipboard-input" value="https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v2.0/planet_2016-06-20_7088ce06a738dcb3104c769adc11ac2c_z0-z5.mbtiles">
			<button class="clipboard-button hint--bottom hint--rounded" data-hint="Copy to clipboard" data-clipboard-target="#world_z0-z5" onclick="setHint(this, 'Copied!')" onmouseout="setHint(this, 'Copy to clipboard')">
			    <img src="/img/clipboard-black.svg" class="clipboard-img" alt="Copy to clipboard">
			</button>
		</div>
	</div>
</div>
<div id="country-list" class="col12">
	<input type="text" id="search_countries" class="search-field" placeholder="Search..." alt="Search countries"/>
</div>
<div id="city-list" class="col12">
	<input type="text" id="search_cities" class="search-field" placeholder="Search..." alt="Search cities"/>
</div>

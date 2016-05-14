---
layout: page
title: Downloads
published: true
---

# Downloads

You can download the entire planet, country or even city extracts. All the extracts contain some world data on lower zoom levels. This lets your map look great without having to download the entire planet. We want you to use our vector tiles to build great stuff. Therefore the vector tiles are under
the [Open Database License](https://tldrlegal.com/license/odc-open-database-license-(odbl)) the same license [OpenStreetMap is using](https://www.openstreetmap.org/copyright).

- Don’t see your country or city listed below? Contribute by submitting a pull request on our list of [countries](https://github.com/osm2vectortiles/osm2vectortiles/blob/master/src/create-extracts/country_extracts.tsv){:target="_blank"} or [cities](https://github.com/osm2vectortiles/osm2vectortiles/blob/master/src/create-extracts/city_extracts.tsv){:target="_blank"}, or [just ask by opening a new issue](https://github.com/osm2vectortiles/osm2vectortiles/issues/new){:target="_blank"}.
- Need any help? [Check out the documentation](/docs/)

<div class="row">
  <div class="col12">
	  <div class="col4 download-section" onclick="showPlanet()">
	    <div class="download-section-circle" style="background-image: url(/img/planet.png)"></div>
	    <h2>Planet</h2>
	  </div>
	  <div class="col4 download-section" onclick="showCountry()">
	  	<div class="download-section-circle" style="background-image: url(/img/country.png);"></div>
	    <h2>Country</h2>
	  </div>
	  <div class="col4 download-section" onclick="showCity()">
	  	<div class="download-section-circle" style="background-image: url(/img/city.png)"></div>
	    <h2>City</h2>
	  </div>
	</div>
</div>

<div id="planet">
	<div class="col12 download-item" onclick="location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/world.mbtiles'">
		<div class="col4 download-title">
			Full Planet
		</div>
		<div class="col2">
			62 GB
		</div>
		<div class="col6">
			MD5: 8f72dc1279d27f0b3e29d27957c7ad7a
		</div>
	</div>
	<div class="col12 download-item">
		<div class="col4 download-title" onclick="location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/world_z0-z5.mbtiles'">
			Planet from zoom level 0 to 5
		</div>
		<div class="col2" onclick="location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/world_z0-z5.mbtiles'">
			20 MB
		</div>
		<div class="col6 clipboard">
			<input id="world_z0-z5" class="clipboard-input" value="https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/world_z0-z5.mbtiles">
			<button class="clipboard-button hint--bottom hint--rounded" data-hint="Copy to clipboard" data-clipboard-target="#world_z0-z5" onclick="setHint(this, 'Copied!')" onmouseout="setHint(this, 'Copy to clipboard')">
			    <img src="/img/clipboard-black.svg" class="clipboard-img" alt="Copy to clipboard">
			</button>
		</div>
	</div>
	<div class="col12 download-item">
		<div class="col4 download-title" onclick="location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/world_z0-z8.mbtiles'">
			Planet from zoom level 0 to 8
		</div>
		<div class="col2" onclick="location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/world_z0-z8.mbtiles'">
			411 MB
		</div>
		<div class="col6 clipboard">
			<input id="world_z0-z8" class="clipboard-input" value="https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/world_z0-z8.mbtiles">
			<button class="clipboard-button hint--bottom hint--rounded" data-clipboard-target="#world_z0-z8" onclick="setHint(this, 'Copied!')" onmouseout="setHint(this, 'Copy to clipboard')">
			    <img src="/img/clipboard-black.svg" class="clipboard-img" alt="Copy to clipboard">
			</button>
		</div>
	</div>
</div>
<div id="country" class="col12">
	<input type="text" id="search_countries" class="search-field" placeholder="Search..." alt="Search countries"/>
</div>
<div id="city" class="col12">
	<input type="text" id="search_cities" class="search-field" placeholder="Search..." alt="Search cities"/>
</div>
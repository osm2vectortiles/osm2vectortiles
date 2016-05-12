---
layout: page
title: Downloads
published: true
---

# Downloads

The rendered vector tiles provided as download are under
the [Open Database License](https://tldrlegal.com/license/odc-open-database-license-(odbl)) the same license [OpenStreetMap is using](https://www.openstreetmap.org/copyright).
The OSM data is from the planet file of [15th of November 2015](http://planet.osm.org/planet/2015/planet-151116.osm.bz2) rendered using [osm2vectortiles **v1.0**](https://github.com/osm2vectortiles/osm2vectortiles/releases/tag/v1.0). The  next rendering will take place in May 2016.

<div class="row">
  <div class="col12">
	  <div class="col4 download-section" onclick="showPlanet()">
	    <h2>Planet</h2>
	    <p>Vector tile data of the entire planet in one file.
	    </p>
	  </div>
	  <div class="col4 download-section" onclick="showCountry()">
	    <h2>Country Extracts</h2>
	    <p>All country extracts consist of a bounding box of the country containing all details down to zoom level 14. At lower zoom levels (z0 to z8) there is still some world data to make maps look good.
	    </p>
	  </div>
	  <div class="col4 download-section" onclick="showCity()">
	    <h2>City Extracts</h2>
	    <p>All city extracts consist of a bounding box of the city containing all details down to zoom level 14. At lower zoom levels (z0 to z8) there is still some world data to make maps look good.
	    </p>
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
	<div class="col12 download-item" onclick="location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/world_z0-z5.mbtiles'">
		<div class="col4 download-title">
			Planet from zoom level 0 to 5
		</div>
		<div class="col2">
			20 MB
		</div>
	</div>
	<div class="col12 download-item" onclick="location.href='https://osm2vectortiles-downloads.os.zhdk.cloud.switch.ch/v1.0/extracts/world_z0-z8.mbtiles'">
		<div class="col4 download-title">
			Planet from zoom level 0 to 8
		</div>
		<div class="col2">
			411 MB
		</div>
	</div>
</div>
<div id="country" class="col12">
	<input type="text" id="search_countries" class="search-field" placeholder="Search..." alt="Search countries"/>
</div>
<div id="city" class="col12">
	<input type="text" id="search_cities" class="search-field" placeholder="Search..." alt="Search cities"/>
</div>
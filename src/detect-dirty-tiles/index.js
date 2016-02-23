var updatedGeometries = require('./updated-geometries.js');
var tileCover = require('./tile-cover.js');

updatedGeometries.getUpdatedGeometries('osm_poi_points', 14, function(geometries) {
	geometries.forEach(function(geometry) {
		var geometryJSON = JSON.parse(geometry.geometry);
		var dirtyTileArray = tileCover.getCoveredTiles(geometryJSON, 14);
		console.log(dirtyTileArray);
	})
});

var fs = require('fs');
var poly = JSON.parse(fs.readFileSync('./line.geojson'));
var tileCover = require('./tile-cover.js');

var geometry = poly.features[0].geometry;
var dirtyTileArray = tileCover.getCoveredTiles(geometry, 4);

console.log(dirtyTileArray);

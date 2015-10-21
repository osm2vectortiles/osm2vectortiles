var fs = require('fs');
var VectorTile = require('vector-tile').VectorTile;
var Protobuf = require('pbf');

var tile = new VectorTile(new Protobuf(fs.readFileSync('./vector.pbf')));

// Contains a map of all layers
tile.layers;

for(var k in tile.layers) {
	var layer = tile.layers[k];
	// place_label: 61 Features
	console.log(k+": "+tile.layers[k].length+" Features");

	var classSet = new Set();
	var typeSet = new Set();
	for(var i=0; i < layer.length; ++i) {
		if(layer.feature(i).properties.class) {
			classSet.add(layer.feature(i).properties.class);
		}
		if(layer.feature(i).properties.type) {
			typeSet.add("class: "+layer.feature(i).properties.class+" type: "+layer.feature(i).properties.type);
		} else {
			//typeSet.add(layer.feature(i).properties);
		}
	}
	// prints all classes available in this layer
	console.log("Has classes: ");
	if(classSet.size === 0) {
		console.log("no classes")
	} else {
		for(var item of classSet ) {
			console.log(item);
		}
	}
	// prints all types available in this class with classname
	console.log("Has types: ");
	if(typeSet.size === 0) {
		console.log("no types")
	} else {
		for(var item of typeSet ) {
			console.log(item);
		}
	}
}

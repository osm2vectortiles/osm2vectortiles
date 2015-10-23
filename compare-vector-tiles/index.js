var fs = require('fs');
var VectorTile = require('vector-tile').VectorTile;
var Protobuf = require('pbf');

function getTileInfo(layers) {
	var layerCount = 0;
	var featureCount = 0;
	var classSet = new Set();
	var typeSet = new Set();

	for(var i in layers) {
		++layerCount;
		var layer = layers[i];
		featureCount += layer.length;
		for(var j = 0; j < layer.length; ++j) {
			var feature = layer.feature(j);
			if(feature.properties.class) {
				classSet.add(feature.properties.class);
			}
			if(feature.properties.type) {
				typeSet.add(feature.properties.class);
			}
		}
	}
	return { "layers": layerCount, "features": featureCount, "classes": classSet.size, "types": typeSet.size };
}

function containsClass(classSet, className) {
	var containsClass = false;
	for(var item of classSet) {
		if(item.name === className) {
			containsClass = true;
			return containsClass;
		} else {
			containsClass = false;
		}
	}
	return containsClass;
}

function addType(classSet, className, type) {
	for(var item of classSet) {
		if(item.name === className) {
			if(type) {
				item.types.add(type);
			} else {
				item.types.add("no type");
			}
		}
	}
	return classSet;
}

function addClass(classSet, className, type) {
	var layerClass = {
		"name": className,
		"types": new Set()
	};

	if(type) {
		layerClass.types.add(type);
	} else {
		layerClass.types.add("no type");
		//layerClass.types.add(layer.feature(i).properties);
	}
	classSet.add(layerClass);
	return classSet;
}

function getSortedItems(unsortedItems, sortByName) {
	var sortedItems = [];
	for(var unsortedItem of unsortedItems) {
		sortedItems.push(unsortedItem);
	}
	if(sortByName) {
		sortedItems.sort(function(a, b) { 
		    if(a.name > b.name) {
		      return 1;
		    }
		    if (a.name < b.name) {
		      return -1;
		    }
			return 0;
		});
	} else {
		sortedItems.sort();
	}
	return sortedItems;
}

function getSortedLayers(layers) {
	var sortedLayerNames = [];
	for(var i in layers) {
		sortedLayerNames.push(i);
	}
	sortedLayerNames.sort();
	var sortedLayers = [];
	for(var layerName of sortedLayerNames) {
		sortedLayers.push({"name": layerName, "layer": layers[layerName]});
	}
	return sortedLayers;
}

function getLayerResult(layerObject, amountOfFeatures) {
	console.log("\n" + layerObject.name + " (features: " + amountOfFeatures + ")");

	var classSet = new Set();
	for(var j=0; j < layerObject.layer.length; ++j) {
		var properties = layerObject.layer.feature(j).properties;
		var className = properties.class;
		var type = properties.type;
		if(className) {
			if(containsClass(classSet, className)){
				classSet = addType(classSet, className, type);
			} else {
				classSet = addClass(classSet, className, type);
			}
		}
	}
	return classSet;
}

function printLayerResult(classSet) {
	if(classSet.size === 0) {
		console.log("\t"+" no class")
	} else {
		for(var item of getSortedItems(classSet, true)) {
			console.log("\t"+item.name);
			for(var sortedType of getSortedItems(item.types)) {
				console.log("\t" + "\t" + sortedType);
			}
		}
	}
}

function printProlog(layers) {
	var tileInfo = getTileInfo(layers);
	console.log("name: open-streets");
	console.log("tile: 10/4141/5356");
	console.log("features: " + tileInfo.features);
	console.log("layers: " + tileInfo.layers);
	console.log("classes: " + tileInfo.classes);
	console.log("types: " + tileInfo.types);
}

function printResult(layers) {
	var layerArray = getSortedLayers(layers);
	for(var i in layerArray) {
		var layerObject = layerArray[i];
		printLayerResult(getLayerResult(layerObject, layers[layerObject.name].length));
	}
}

var tile = new VectorTile(new Protobuf(fs.readFileSync('./vector.pbf')));
printProlog(tile.layers);
printResult(tile.layers);

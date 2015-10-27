function getTileInfo(layers) {
	var layerCount = 0;
	var featureCount = 0;
	var classSet = new Set();
	var typeSet = new Set();
	var attributeSet = new Set();

	for(var i in layers) {
		++layerCount;
		var layer = layers[i];
		featureCount += layer.length;
		for(var j = 0; j < layer.length; ++j) {
			var feature = layer.feature(j);
			for(var property in feature.properties) {
				if(feature.properties.hasOwnProperty(property)) {
					attributeSet.add(property);
				}
			}
			if(feature.properties.class) {
				classSet.add(feature.properties.class);
			}
			if(feature.properties.type) {
				typeSet.add(feature.properties.class);
			}
		}
	}
	return { "layers": layerCount, "features": featureCount, "classes": classSet.size, "types": typeSet.size, "attributes": getSortedSet(attributeSet) };
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

function addProperties(layerClass, properties) {
	for(var property in properties) {
		if(properties.hasOwnProperty(property)) {
			if(!(property === 'class' || property === 'type')) {
				layerClass.attributes.add(property);
			}
		}
	}
	return layerClass;
}

function addType(classSet, className, type, properties) {
	for(var item of classSet) {
		if(item.name === className) {
			if(type) {
				item.types.add(type);
			} else {
				item.types.add("no type");
			}
			item = addProperties(item, properties);
		}
	}
	return classSet;
}

function addClass(classSet, className, type, properties) {
	var layerClass = {
		"name": className,
		"types": new Set(),
		"attributes": new Set()
	};

	if(className === 'admin' || className === 'marine_label') {
		console.log(properties);
	}

	if(type) {
		layerClass.types.add(type);
	} else {
		layerClass.types.add("no type");
	}

	layerClass = addProperties(layerClass, properties);
	classSet.add(layerClass);
	return classSet;
}

function getSortedSet(unsortedSet) {
	var sortedArray = [];
	unsortedSet.forEach(function(item) {
		sortedArray.push(item);
	});
	sortedArray.sort();
	return sortedArray;
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
	output += "\n" + "#" + layerObject.name + " (features: " + amountOfFeatures + ")" + "\n";

	var classSet = new Set();
	for(var j=0; j < layerObject.layer.length; ++j) {
		var properties = layerObject.layer.feature(j).properties;
		var className = properties.class;
		var type = properties.type;
		if(className) {
			if(containsClass(classSet, className)){
				classSet = addType(classSet, className, type, properties);
			} else {
				classSet = addClass(classSet, className, type, properties);
			}
		}
	}
	return classSet;
}

function printLayerResult(classSet) {
	var attributeSet = new Set();
	classSet.forEach(function(item) {
		item.attributes.forEach(function(attribute) {
			attributeSet.add(attribute);
		});
	});
	
	getSortedSet(attributeSet).forEach(function(attribute) {
		output += "\t"+"[" + attribute + "]" + "\n";
	});

	if(classSet.size === 0) {
		output += "\t"+" no class" + "\n";
	} else {
		for(var item of getSortedItems(classSet, true)) {

			output += "\t" + item.name + "\n";
			for(var sortedType of getSortedItems(item.types)) {
				output += "\t" + "\t" + sortedType + "\n";
			}
		}
	}
}

function printProlog(layers, name, tileNumber) {
	var tileInfo = getTileInfo(layers);
	output += "name: " + name + "\n";
	output += "tile: " + tileNumber + "\n";
	output += "features: " + tileInfo.features + "\n";
	output += "layers: " + tileInfo.layers + "\n";
	output += "classes: " + tileInfo.classes + "\n";
	output += "types: " + tileInfo.types + "\n";
	output += "common attributes over all layers:" + "\n";
	tileInfo.attributes.forEach(function(attribute) {
		output += "\t" + "[" + attribute + "]" + "\n";
	});
}

function printResult(layers) {
	var layerArray = getSortedLayers(layers);
	for(var i in layerArray) {
		var layerObject = layerArray[i];
		printLayerResult(getLayerResult(layerObject, layers[layerObject.name].length));
	}
}

var output = "";

exports.printOutput = function(layers, name, tileNumber) {
	printProlog(layers, name, tileNumber);
	printResult(layers);
	var result = output;
	output = "";
	return result;
}

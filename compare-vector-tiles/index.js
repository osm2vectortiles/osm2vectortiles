var fs = require('fs');
var mkdirp = require('mkdirp');
var VectorTile = require('vector-tile').VectorTile;
var Protobuf = require('pbf');
var tileInformation = require('./tileInformation.js');
var http = require('http');

var urls = ['0-0-0', '1-1-0', '2-2-0', '3-4-2', '4-8-5', '5-16-11', '6-33-22', '7-67-44', '8-134-89', '9-268-179', '10-536-358', '11-1072-717', '12-2145-1434', '13-4290-2868', '14-8580-5737', '15-17161-11474'];

function processTiles(directory, name) {
	urls.forEach(function(url) {
		var filePath = directory + url + ".vector.pbf";
		var tile = new VectorTile(new Protobuf(fs.readFileSync(filePath)));
		var url1 = url.replace('-', '/');
		var url2 = url1.replace('-', '/');
		var output = tileInformation.printOutput(tile.layers, name, url2);
		writeOutput(output, name, url);
	});
	console.log("Output for style " + name + " written.");
}

function writeOutput(output, dirname, name) {
	mkdirp('./output/' + dirname, function(err) {
		if(err) {
			console.log("Error creating dir: " + err);
		} else {
			var filename = "./output/" + dirname + "/"+ name;
			fs.writeFile(filename, output, function(err) {
			    if(err) {
			        console.log("Error writing file: " + err);
			    }
			});

		}
	});
}

function generateOutputFiles(styles) {
	styles.forEach(function(style) {
		var directory = 'vector-tiles/' + style + '/';
		processTiles(directory, style);
	});
}

var styles = ['open-streets', 'mapbox-streets-v5', 'mapbox-streets-v6'];
generateOutputFiles(styles);
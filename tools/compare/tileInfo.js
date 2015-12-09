#!/usr/bin/env node

var VectorTile = require('vector-tile').VectorTile;
var Protobuf = require('pbf');
var tileInformation = require('./lib/tileInfo.js');
var program = require('commander');
var zlib = require('zlib');
var tilelive = require('tilelive');
require('mbtiles').registerProtocols(tilelive);

program
  .version('0.0.1')
  .usage('-m mapbox-streets-v6.mbtiles -z 5 -x 16 -y 11 -p mapbox-streets-v6')
  .option('-m, --mbtiles <path>', 'Path to mbtiles file')
  .option('-x, --x <x>', 'X value')
  .option('-y, --y <y>', 'Y value')
  .option('-z, --z <z>', 'Z value')
  .option('-p, --provider <provider>', 'Vector tile provider')
  .parse(process.argv);
if(!program.mbtiles || !program.x || !program.y || !program.z || !program.provider) {
	program.help();
}

tilelive.load("mbtiles://./" + program.mbtiles, function(err, src) {
    if (err) {
      throw err;
    }

    return src.getTile(program.z, program.x, program.y, function(err, tile, headers) {
      if (err) {
        throw err;
      }
      zlib.unzip(tile, function(err, tile) {
	    if (!err) {
      		var rawTile = new VectorTile(new Protobuf(tile))
      		var tileName = program.z + "-" + program.x + "-" + program.y;
      		var tileInfo = tileInformation.printOutput(rawTile.layers, program.provider, tileName);
      		console.log(tileInfo);
      	}
	  });
    });
});

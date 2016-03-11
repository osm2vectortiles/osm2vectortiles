var _ = require('underscore');
var q = require('q');
var fs = require('fs');
var path = require('path');

var pgp = require('pg-promise')({
    promiseLib: q
});
var db = pgp({
    host: process.env.DB_PORT_5432_TCP_ADDR,
    port: 5432,
    database: 'osm',
    user: 'osm',
    password: 'osm'
});

var timeLabel = 'Time to calculate changed tiles';
var exportDir = process.env.EXPORT_DIR || '/data/export/';
var changedTilesListFile = process.env.LIST_FILE || path.join(exportDir, 'tiles.txt');

function changedTilesList() {
    return db.task(function (t) {
        return t.one('SELECT MAX(timestamp) FROM osm_timestamps')
        .then(function (result) {
            return t.batch([
                changed_tiles('admin'),
                changed_tiles('aeroway'),
                changed_tiles('barrier_line'),
                changed_tiles('bridge'),
                changed_tiles('building'),
                changed_tiles('housenum_label'),
                changed_tiles('landuse'),
                changed_tiles('landuse_overlay'),
                changed_tiles('place_label'),
                changed_tiles('poi_label'),
                changed_tiles('road'),
                changed_tiles('road_label'),
                changed_tiles('tunnel'),
                changed_tiles('water'),
                changed_tiles('water_label'),
                changed_tiles('waterway'),
                changed_tiles('waterway_label')
            ]);

            function changed_tiles(layer) {
                return t.any('SELECT * FROM changed_tiles_' + layer + '($1)',
                    [result.max])
                    .then(function (rows) {
                        return {
                            layer: layer,
                            changed_tiles: rows
                        };
                    });
            }

        });
    })
    .then(_.flatten);
}

console.time(timeLabel);
changedTilesList().then(function (layers) {
    var tileList = _.uniq(_.flatten(
        layers.map(function (layer) {
            return layer.changed_tiles;
        })
    ).map(function (tile) {
        return tile.z + '/' + tile.x + '/' + tile.y;
    })).join('\n');
    console.timeEnd(timeLabel);

    console.log('Write changed tiles to ' + changedTilesListFile);
    console.log(tileList);

    fs.writeFileSync(changedTilesListFile, tileList, {
        encoding: 'utf8'
    });
}).catch(function (err) {
    console.error(err);
});

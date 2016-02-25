var _ = require('underscore');
var q = require('q');
var pgp = require('pg-promise')();
var fs = require('fs');
var path = require('path');

var db = pgp({
    host: process.env.DB_PORT_5432_TCP_ADDR,
    port: 5432,
    database: 'osm',
    user: 'osm',
    password: 'osm'
});

var exportDir = process.env.EXPORT_DIR || '/data/export/';
var dirtyTilesListFile = process.env.LIST_FILE || path.join(exportDir, 'tiles.txt');

function detectDirtyTiles(viewName, timestamp, minZoomLevel, maxZoomLevel) {
    return db.query(
        'SELECT * FROM detect_dirty_tiles($1, $2) WHERE z BETWEEN $3 AND $4',
        [viewName, timestamp, minZoomLevel, maxZoomLevel]
    ).then(function(rows) {
        return {
            viewName: viewName,
            dirtyTiles: rows
        };
    });
}

function recentDirtyViews() {
    return db
        .one('SELECT MAX(timestamp) FROM osm_timestamps')
        .then(function(result) { return result.max; })
        .then(function(timestamp) {
            return q.all([
                detectDirtyTiles('water_label_z10', timestamp, 10, 10),
                detectDirtyTiles('water_label_z11', timestamp, 11, 11),
                detectDirtyTiles('water_label_z12', timestamp, 12, 12),
                detectDirtyTiles('water_label_z13', timestamp, 13, 13),
                detectDirtyTiles('water_label_z14', timestamp, 14, 14),
                detectDirtyTiles('poi_label_z14', timestamp, 14, 14),
                detectDirtyTiles('road_label_z8toz10', timestamp, 8, 10),
                detectDirtyTiles('road_label_z11', timestamp, 11, 11),
                detectDirtyTiles('road_label_z12toz13', timestamp, 12, 13),
                detectDirtyTiles('road_label_z14', timestamp, 14, 14),
                detectDirtyTiles('waterway_label_z8toz12', timestamp, 8, 12),
                detectDirtyTiles('waterway_label_z13toz14', timestamp, 13, 14)
            ]);
        }).then(_.flatten);
}

recentDirtyViews().then(function(dirtyViews) {
    var tileList = _.flatten(
        dirtyViews.map(function(view) { return view.dirtyTiles; })
    ).map(function(tile) {
        return tile.z + '/' + tile.x + '/' + tile.y;
    }).join('\n');

    console.log('Write dirty tiles to ' + dirtyTilesListFile);
    console.log(tileList);

    fs.writeFileSync(dirtyTilesListFile, tileList, {
        encoding: 'utf8'
    });
}).catch(function(err) {
    console.error(err);
});

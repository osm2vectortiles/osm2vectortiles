var _ = require('underscore');
var q = require('q');
var fs = require('fs');
var path = require('path');
var coveredTiles = require('./coveredTiles.js');

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

var exportDir = process.env.EXPORT_DIR || '/data/export/';
var dirtyTilesListFile = process.env.LIST_FILE || path.join(exportDir, 'tiles.txt');

function queryChanges(timestamp, viewName) {
    return db.query(
        'SELECT osm_id, ST_AsGeoJSON(ST_Transform(geometry, 4326)) AS geometry ' +
        'FROM ' + viewName + ' ' +
        'WHERE timestamp=$1', [timestamp]
    ).then(function(rows) {
        return rows.map(function(row) {
            return {
                osmId: row.osm_id,
                geometry: JSON.parse(row.geometry)
            };
        });
    });
}

function affectedTiles(timestamp, viewName, minZoomLevel, maxZoomLevel) {
    return queryChanges(timestamp, viewName).then(function(rows) {
        return rows.map(function(row) {
            return {
                view: viewName,
                osmId: row.osmId,
                affectedTiles: coveredTiles(row.geometry, minZoomLevel, maxZoomLevel)
            };
        });
    });
}

function recentDirtyViews() {
    return db.one('SELECT MAX(timestamp) FROM osm_timestamps')
    .then(function (result) {
        var timestamp = result.max;

        function detectDirtyTiles(viewName, minZoomLevel, maxZoomLevel) {
            return affectedTiles(timestamp, viewName, minZoomLevel, maxZoomLevel);
        }

        return q.all([
            detectDirtyTiles('landuse_z5', 5, 5),
            detectDirtyTiles('landuse_z6', 6, 6),
            detectDirtyTiles('landuse_z7', 7, 7),
            detectDirtyTiles('landuse_z8', 8, 8),
            detectDirtyTiles('landuse_z9', 9, 9),
            detectDirtyTiles('landuse_z10', 10, 10),
            detectDirtyTiles('landuse_z11', 11, 11),
            detectDirtyTiles('landuse_z12', 12, 12),
            detectDirtyTiles('landuse_z13toz14', 13, 14),
            detectDirtyTiles('waterway_z8toz12', 8, 12),
            detectDirtyTiles('waterway_z13toz14', 13, 14),
            detectDirtyTiles('water_z6toz12', 6, 12),
            detectDirtyTiles('water_z13toz14', 13, 14),
            detectDirtyTiles('aeroway_z12toz14', 12, 14),
            detectDirtyTiles('barrier_line_z14', 14, 14),
            detectDirtyTiles('landuse_overlay_z7', 7, 7),
            detectDirtyTiles('landuse_overlay_z8', 8, 8),
            detectDirtyTiles('landuse_overlay_z9', 9, 9),
            detectDirtyTiles('landuse_overlay_z10', 10, 10),
            detectDirtyTiles('landuse_overlay_z11toz12', 11, 12),
            detectDirtyTiles('landuse_overlay_z13toz14', 13, 14),
            detectDirtyTiles('tunnel_z12toz14', 12, 14),
            detectDirtyTiles('road_z5to6', 5, 6),
            detectDirtyTiles('road_z7', 7, 7),
            detectDirtyTiles('road_z8to10', 8, 10),
            detectDirtyTiles('road_z11', 11, 11),
            detectDirtyTiles('road_z12', 12, 12),
            detectDirtyTiles('road_z13', 13, 13),
            detectDirtyTiles('road_z14', 14, 14),
            detectDirtyTiles('bridge_z12to14', 12, 14),
            detectDirtyTiles('admin_z2to6', 2, 6),
            detectDirtyTiles('admin_z7to14', 7, 14),
            detectDirtyTiles('place_label_z4toz5', 4, 5),
            detectDirtyTiles('place_label_z6', 6, 6),
            detectDirtyTiles('place_label_z7', 7, 7),
            detectDirtyTiles('place_label_z8', 8, 8),
            detectDirtyTiles('place_label_z9toz10', 9, 10),
            detectDirtyTiles('place_label_z11toz12', 11, 12),
            detectDirtyTiles('place_label_z13', 13, 13),
            detectDirtyTiles('place_label_z14', 14, 14),
            detectDirtyTiles('water_label_z10', 10, 10),
            detectDirtyTiles('water_label_z11', 11, 11),
            detectDirtyTiles('water_label_z12', 12, 12),
            detectDirtyTiles('water_label_z13', 13, 13),
            detectDirtyTiles('water_label_z14', 14, 14),
            detectDirtyTiles('poi_label_z14', 14, 14),
            detectDirtyTiles('road_label_z8toz10', 8, 10),
            detectDirtyTiles('road_label_z11', 11, 11),
            detectDirtyTiles('road_label_z12toz13', 12, 13),
            detectDirtyTiles('road_label_z14', 14, 14),
            detectDirtyTiles('waterway_label_z8toz12', 8, 12),
            detectDirtyTiles('waterway_label_z13toz14', 13, 14)
        ]);
    }).then(_.flatten);
}

recentDirtyViews().then(function (dirtyViews) {
    var timeLabel = 'Time to calculate dirty tiles';
    console.time(timeLabel);
    var tileList = _.uniq(_.flatten(
        dirtyViews.map(function (view) {
            return view.affectedTiles;
        })
    ).map(function (tile) {
        return tile.z + '/' + tile.x + '/' + tile.y;
    })).join('\n');

    console.timeEnd(timeLabel);
    console.log('Write dirty tiles to ' + dirtyTilesListFile);
    fs.writeFileSync(dirtyTilesListFile, tileList, {
        encoding: 'utf8'
    });
}).catch(function (err) {
    console.error(err);
});

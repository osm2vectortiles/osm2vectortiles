var _ = require('underscore');
var q = require('q');
var pgp = require('pg-promise')();

var db = pgp({
    host: process.env.DB_PORT_5432_TCP_ADDR,
    port: 5432,
    database: 'osm',
    user: 'osm',
    password: 'osm'
});

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
                detectDirtyTiles('place_label_z4toz5', timestamp, 4, 5),
                detectDirtyTiles('place_label_z6', timestamp, 6, 6),
                detectDirtyTiles('place_label_z7', timestamp, 7, 7),
                detectDirtyTiles('place_label_z8', timestamp, 8, 8),
                detectDirtyTiles('place_label_z9toz10', timestamp, 9, 10),
                detectDirtyTiles('place_label_z11toz12', timestamp, 11, 12),
                detectDirtyTiles('place_label_z13', timestamp, 13, 13),
                detectDirtyTiles('place_label_z14', timestamp, 14, 14),
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
                detectDirtyTiles('waterway_label_z13toz14', timestamp, 13, 14),
                detectDirtyTiles('housenum_label', timestamp, 14, 14)
            ]);
        }).then(_.flatten);
}

recentDirtyViews().then(function(dirtyViews) {
    console.log(JSON.stringify(dirtyViews, null, 2));
}).catch(function(err) {
    console.error(err);
});

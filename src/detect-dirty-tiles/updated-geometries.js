var pgp = require('pg-promise')();
var tileCover = require('./tile-cover.js');
var db = pgp({
    host: process.env.DB_PORT_5432_TCP_ADDR,
    port: 5432,
    database: 'osm',
    user: 'osm',
    password: 'osm'
});

function updatedPoiPoints(timestamp) {
    return db.query('SELECT osm_id, ST_AsGeoJSON(ST_Transform(geometry, 4326)) AS geometry FROM osm_poi_points WHERE timestamp=${timestamp}', { timestamp: timestamp }).then(function(rows) {
        return rows.map(function(row) {
            return {
                osmId: rows.osm_id,
                geometry: JSON.parse(row.geometry)
            };
        });
    });
}

exports.getUpdatedGeometries = function(tableName, zoomLevel) {

    if (tableName == 'osm_poi_points' && zoomLevel == 14) {
        return db
            .one('SELECT MAX(timestamp) FROM osm_poi_points')
            .then(function(result) { return updatedPoiPoints(result.max); })
            .then(function(poiPoints) {
                return poiPoints.map(function(poiPoint) {
                    return {
                        osmId: poiPoint.osm_id,
                        table: 'osm_poi_points',
                        affectedTiles: tileCover.coveredTiles(poiPoint.geometry, zoomLevel)
                    };
                });
            });
    }
};

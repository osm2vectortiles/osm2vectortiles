var q = require('q');
var _ = require('underscore');
var pgp = require('pg-promise')();
var tileCover = require('./tile-cover.js');

var db = pgp({
    host: process.env.DB_PORT_5432_TCP_ADDR,
    port: 5432,
    database: 'osm',
    user: 'osm',
    password: 'osm'
});

function parseRow(row) {
    return {
        osmId: row.osm_id,
        geometry: JSON.parse(row.geometry)
    };
}

function queryChanges(timestamp, tableName, constraints) {
    return db.query(
        'SELECT osm_id, ST_AsGeoJSON(ST_Transform(geometry, 4326)) AS geometry ' +
        'FROM ' + tableName + ' ' +
        'WHERE timestamp=$1 AND ' + constraints, [timestamp]
    ).then(function(rows) {
        return rows.map(parseRow);
    });
}

function affectedTiles(timestamp, tableName, zoomLevel, constraints) {
    return queryChanges(timestamp, tableName, constraints).then(function(rows) {
        return rows.map(function(row) {
            return {
                table: tableName,
                osmId: row.osmId,
                affectedTiles: tileCover.coveredTiles(row.geometry, zoomLevel)
            };
        });
    });
}

function pointOfInterests(timestamp) {
    return q.all(
        affectedTiles(timestamp, 'osm_poi_points', 14, "name <> ''"),
        affectedTiles(timestamp, 'osm_poi_polygons', 14, "name <> ''")
    ).then(_.flatten);
}

function landuse(timestamp) {
    function hasForest() {
        return "type IN ('wood', 'nature_reserve', 'national_park', 'forest')";
    }

    function hasNoOverlay() {
        return "type NOT IN ('wetland', 'marsh', 'swamp', 'bog', 'mud', 'tidalflat')";
    }

    function hasLargerArea(areaThreshold) {
        return 'st_area(geometry) > ' + areaThreshold;
    }

    function combine(constraint1, constraint2) {
        return constraint1 + ' AND ' + constraint2;
    }

    return q.all([
        affectedTiles(
            timestamp, 'osm_landusages_gen0', 5,
            combine(hasForest(), hasLargerArea(300000000))
        ),
        affectedTiles(
            timestamp, 'osm_landusages_gen0', 6,
            combine(hasForest(), hasLargerArea(100000000))
        ),
        affectedTiles(
            timestamp, 'osm_landusages_gen0', 7,
            combine(hasForest(), hasLargerArea(25000000))
        ),
        affectedTiles(
            timestamp, 'osm_landusages_gen0', 8,
            combine(hasForest(), hasLargerArea(5000000))
        ),
        affectedTiles(
            timestamp, 'osm_landusages_gen0', 9,
            combine(hasForest(), hasLargerArea(2000000))
        ),
        affectedTiles(
            timestamp, 'osm_landusages_gen0', 10,
            combine(hasForest(), hasLargerArea(500000))
        ),
        affectedTiles(
            timestamp, 'osm_landusages_gen1', 11,
            combine(hasForest(), hasLargerArea(100000))
        ),
        affectedTiles(
            timestamp, 'osm_landusages', 12,
            combine(hasForest(), hasLargerArea(10000))
        ),
        affectedTiles(
            timestamp, 'osm_landusages', 13,
            hasNoOverlay()
        )
    ]).then(_.flatten);
}

exports.getUpdatedGeometries = function() {
    return db
        .one('SELECT MAX(timestamp) FROM osm_poi_points')
        .then(function(result) { return result.max; })
        .then(function(timestamp) {
            return q.all([
                pointOfInterests(timestamp),
                landuse(timestamp)
            ]);
        }).then(_.flatten);
};

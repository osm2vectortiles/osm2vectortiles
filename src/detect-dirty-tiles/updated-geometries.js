var pgp = require('pg-promise')();
var db = pgp({
    host: process.env.DB_PORT_5432_TCP_ADDR,
    port: 5432,
    database: 'osm',
    user: 'osm',
    password: 'osm'
});

exports.getUpdatedGeometries = function(tableName, zoomLevel, callback){
    var dbQuery = db.query('SELECT ST_AsGeoJSON(geometry) AS geometry FROM osm_poi_points WHERE timestamp IS NULL');

    dbQuery.then(callback).catch(function(error) {
        console.error(error);
    });
};

var pg = require('promise-pg');
var db = pgp({
    host: process.env.DB_HOST || 'postgis',
    port: 5432,
    database: process.env.DB_NAME || 'osm',
    user: process.env.DB_USER ||  'osm',
    password: process.env.DB_PASSWORD ||  'osm'
});

exports.getUpdatedGeometries = function(tableName, zoomLevel, callback){
	var dbQuery = db.query(
        "SELECT id, name FROM public.communities_search WHERE name ILIKE '$1^%' OR zip::text = $1",
        searchQuery
    );

    dbQuery.then(function(data) {
    	callback(data);
    })
    .catch(function(error) {
    	console.error(error);
    })
}

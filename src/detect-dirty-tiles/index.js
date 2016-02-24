var updatedGeometries = require('./updated-geometries.js');

updatedGeometries.getUpdatedGeometries('osm_poi_points', 14).then(function(geometries) {
    console.log(JSON.stringify(geometries, null, 2));
}).catch(function(err) {
    console.error(err);
});

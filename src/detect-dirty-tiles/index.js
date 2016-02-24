var updatedGeometries = require('./updated-geometries.js');

updatedGeometries.getUpdatedGeometries().then(function(geometries) {
    console.log(JSON.stringify(geometries, null, 2));
}).catch(function(err) {
    console.error(err);
});

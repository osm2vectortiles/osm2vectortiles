var _ = require('underscore');
var updatedGeometries = require('./updated-geometries.js');

updatedGeometries.getUpdatedGeometries().then(function(geometries) {
    var statistics = _.countBy(geometries, function(geom) {
        return geom.table;
    });
    console.log(statistics);
}).catch(function(err) {
    console.error(err);
});

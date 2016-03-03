var cover = require('tile-cover');

module.exports = function(geometry, minZoomLevel, maxZoomLevel) {
    var limits = {
        min_zoom: minZoomLevel,
        max_zoom:maxZoomLevel
    };

    return cover.tiles(geometry, limits).map(function(tile) {
        return {
            x: tile[0],
            y: tile[1],
            z: tile[2]
        };
    });
};

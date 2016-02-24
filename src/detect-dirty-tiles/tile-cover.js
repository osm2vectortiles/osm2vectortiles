var cover = require('tile-cover');

exports.coveredTiles = function(geometry, zoomLevel) {
    var limits = {
        min_zoom: zoomLevel,
        max_zoom: zoomLevel
    };
    return cover.tiles(geometry, limits);
};

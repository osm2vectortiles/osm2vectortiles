var _ = require('underscore');
var cover = require('tile-cover');

module.exports = function(geometry, minZoomLevel, maxZoomLevel) {
    return _.flatten(_.range(minZoomLevel, maxZoomLevel + 1)
            .map(function(zoomLevel) {
                var limits = {
                    min_zoom: zoomLevel,
                    max_zoom: zoomLevel
                };
                return cover.tiles(geometry, limits).map(function(tile) {
                    return {
                        x: tile[0],
                        y: tile[1],
                        z: tile[2]
                    };
                });
            })
    );
};

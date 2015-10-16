import mercantile


def all_descendant_tiles(x, y, zoom, max_zoom):
    """Return all subtiles contained within a tile"""
    if zoom < max_zoom:
        for child_tile in mercantile.children(x, y, zoom):
            yield child_tile
            yield from all_descendant_tiles(child_tile.x, child_tile.y,
                                            child_tile.z, max_zoom)

def tiles_for_zoom_level(zoom_level):
    # Only switzerland for now
    tiles = all_descendant_tiles(x=32, y=22, zoom=6, max_zoom=zoom_level)

    for tile in tiles:
        if tile.z == zoom_level:
            yield tile


if __name__ == '__main__':
    for tile in tiles_for_zoom_level(10):
        bbox = mercantile.bounds(tile.x, tile.y, tile.z)
        wgs84 = "{} {} {} {}".format(bbox.west, bbox.south, bbox.east, bbox.north)
        print(wgs84)

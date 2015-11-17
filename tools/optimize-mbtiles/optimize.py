#!/usr/bin/env python
"""Remove descendant tiles below a parent tile with specified mask level.
Usage:
  optimize.py check <mbtiles_file> -z=<mask_level> [--scheme=<scheme>]
  optimize.py remove <mbtiles_file> -z=<mask_level> [--scheme=<scheme>]
  optimize.py (-h | --help)
  optimize.py --version

Options:
  -h --help                 Show this screen.
  --version                 Show version.
  -z=<mask_level>           Minimum zoom level where data should still exist
  --scheme=<scheme>         Tiling scheme of the tiles can be either xyz or tms [default: tms]
"""
from collections import defaultdict, namedtuple, Counter
from docopt import docopt

import hashlib
import mbutil
import mercantile

TileSize = namedtuple('TileSize', ['x', 'y', 'z', 'size'])

class MBTiles:
    def __init__(self, mbtiles_file, scheme):
        self.conn = mbutil.mbtiles_connect(mbtiles_file)
        self.scheme = scheme

    def tiles_at_zoom_level(self, z):
        query = (
            'select tile_column, tile_row, length(tile_data) from tiles where zoom_level={}'
            .format(z)
        )
        for tile in self.conn.execute(query):
            x = tile[0]
            y = tile[1]
            size = tile[2]

            if self.scheme == 'tms':
                y = mbutil.flip_y(z, y)
            yield mercantile.Tile(x, y, z)


    def inspect_tile(self, x, y, z):
        if self.scheme == 'tms':
            y = mbutil.flip_y(z, y)

        query = (
            'select tile_data from tiles where zoom_level={} and tile_column={} and tile_row={}'
            .format(z, x, y)
        )
        rs = self.conn.execute(query).fetchone()
        if rs:
            raw = rs[0]
            return hashlib.sha1(raw).hexdigest()
        else:
            return None


def all_descendant_tiles(x, y, zoom, max_zoom):
    """Return all subtiles contained within a tile"""
    if zoom < max_zoom:
        for child_tile in mercantile.children(x, y, zoom):
            yield child_tile
            yield from all_descendant_tiles(child_tile.x, child_tile.y,
                                            child_tile.z, max_zoom)



def find_optimizable_tiles(mbtiles_file, maskLevel, scheme):
    mbtiles = MBTiles(mbtiles_file, scheme)
    parent_tiles = [t for t in mbtiles.tiles_at_zoom_level(maskLevel)]

    def descendant_checksums(x, y, zoom, max_zoom):
        for tile in all_descendant_tiles(x, y, zoom, max_zoom=14):
            yield mbtiles.inspect_tile(tile.x, tile.y, tile.z)

    for tile in parent_tiles:
        parent_checksum = mbtiles.inspect_tile(tile.x, tile.y, tile.z)
        counter = Counter(descendant_checksums(tile.x, tile.y, tile.z, 14))

        checksum, _ = counter.most_common(1)[0]
        if parent_checksum == checksum and len(counter) == 1:
            yield tile


def check_masked_tiles(mbtiles_file, maskLevel, scheme):
    for tile in find_optimizable_tiles(mbtiles_file, maskLevel, scheme):
        print('{}/{}/{}\t{}'.format(tile.z, tile.x, tile.y, 'OPTIMIZABLE'))

if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')
    if args.get('check'):
        check_masked_tiles(
            args['<mbtiles_file>'],
            int(args['-z']),
            args['--scheme']
        )

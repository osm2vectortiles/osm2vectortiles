#!/usr/bin/env python
"""Verify MBTiles contains all descendant tiles of a given tile.
Usage:
  verify.py <mbtiles_file> <x> <y> -z=<min_zoom> -Z=<max_zoom> [--scheme=<scheme>]
  verify.py (-h | --help)
  verify.py --version

Options:
  -h --help                 Show this screen.
  --version                 Show version.
  -z=<min_zoom>             Minimum zoom to start verifying
  -Z=<max_zoom>             Maximum zoom to verify
  --scheme=<scheme>         Tiling scheme of the tiles can be either xyz or tms [default: tms]
"""
from collections import defaultdict

from docopt import docopt
from blessings import Terminal
import mbutil
import mercantile


class MBTiles:
    def __init__(self, mbtiles_file, scheme):
        self.conn = mbutil.mbtiles_connect(mbtiles_file)
        self.scheme = scheme

    def all_tiles(self):
        tiles = self.conn.execute('select zoom_level, tile_column, tile_row from tiles;')
        for tile in tiles:
            z = tile[0]
            x = tile[1]
            y = tile[2]

            if self.scheme == 'tms':
                y = mbutil.flip_y(z, y)
            yield mercantile.Tile(x, y, z)

    def tile_exists(self, x, y, z):
        if self.scheme == 'tms':
            y = mbutil.flip_y(z, y)
        query = (
            'select count(*) from tiles where zoom_level={} and tile_column={} and tile_row={};'
            .format(z, x, y)
        )
        rs = self.conn.execute(query).fetchone()
        return rs[0] == 1


def all_descendant_tiles(x, y, zoom, max_zoom):
    """Return all subtiles contained within a tile"""
    if zoom < max_zoom:
        for child_tile in mercantile.children(x, y, zoom):
            yield child_tile
            yield from all_descendant_tiles(child_tile.x, child_tile.y,
                                            child_tile.z, max_zoom)


def redundant_tiles(mbtiles, required_tiles):
    """All tiles that should not be in MBTiles"""
    xyz_dict= lambda: defaultdict(xyz_dict)

    # Mark all tiles that are required
    marked_tiles = xyz_dict()
    for tile in required_tiles:
        marked_tiles[tile.z][tile.x][tile.y] = True


    for tile in mbtiles.all_tiles():
        required = marked_tiles[tile.z][tile.x][tile.y]
        if required != True:
            yield tile


def missing_tiles(mbtiles, required_tiles):
    """All tiles that should be in MBTiles but are missing"""
    for tile in required_tiles:
        if not mbtiles.tile_exists(tile.x, tile.y, tile.z):
            yield tile


def verify_tiles(mbtiles_file, x, y, min_zoom, max_zoom, scheme):
    root_tile = mercantile.Tile(x, y, min_zoom)
    mbtiles = MBTiles(mbtiles_file, scheme)
    required_tiles = list(all_descendant_tiles(x, y, min_zoom, max_zoom))
    required_tiles += [root_tile]

    for tile in missing_tiles(mbtiles, required_tiles):
        print('{}/{}/{}\t{}'.format(tile.z, tile.x, tile.y, 'MISSING'))

    for tile in redundant_tiles(mbtiles, required_tiles):
        print('{}/{}/{}\t{}'.format(tile.z, tile.x, tile.y, 'REDUNDANT'))


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')
    verify_tiles(
        args['<mbtiles_file>'],
        int(args['<x>']),
        int(args['<y>']),
        int(args['-z']),
        int(args['-Z']),
        args['--scheme']
    )

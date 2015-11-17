#!/usr/bin/env python
"""Verify MBTiles contains all descendant tiles of a given tile.
Usage:
  verify.py redundant <mbtiles_file> <x> <y> -z=<min_zoom> -Z=<max_zoom> [--scheme=<scheme>]
  verify.py missing <mbtiles_file> <x> <y> -z=<min_zoom> -Z=<max_zoom> [--scheme=<scheme>]
  verify.py size <mbtiles_file> -s=<max_size> [--scheme=<scheme>]
  verify.py (-h | --help)
  verify.py --version

Options:
  -h --help                 Show this screen.
  --version                 Show version.
  -s=<max_size>             Maximum size of tile data in bytes
  -z=<min_zoom>             Minimum zoom to start verifying
  -Z=<max_zoom>             Maximum zoom to verify
  --scheme=<scheme>         Tiling scheme of the tiles can be either xyz or tms [default: tms]
"""
from collections import defaultdict, namedtuple

from docopt import docopt
import humanize
import mbutil
import mercantile

TileSize = namedtuple('TileSize', ['x', 'y', 'z', 'size'])


class MBTiles:
    def __init__(self, mbtiles_file, scheme):
        self.conn = mbutil.mbtiles_connect(mbtiles_file)
        self.scheme = scheme

    def tiles_by_size(self, max_size):
        tiles = self.conn.execute("""
            select zoom_level, tile_column, tile_row, length(tile_data) from tiles
            where length(tile_data) > {}
        """.format(max_size))
        for tile in tiles:
            z = tile[0]
            x = tile[1]
            y = tile[2]
            size = tile[3]

            if self.scheme == 'tms':
                y = mbutil.flip_y(z, y)
            yield TileSize(x, y, z, size)


    def all_tiles(self):
        tiles = self.conn.execute('select zoom_level, tile_column, tile_row from tiles')
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
            'select count(*) from tiles where zoom_level={} and tile_column={} and tile_row={}'
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


def verify_size(mbtiles_file, max_size, scheme):
    mbtiles = MBTiles(mbtiles_file, scheme)
    for tile in mbtiles.tiles_by_size(max_size):
        print('{}/{}/{}\t{}'.format(tile.z, tile.x, tile.y,
                                        humanize.naturalsize(tile.size)))


def list_required_tiles(x, y, min_zoom, max_zoom):
    root_tile = mercantile.Tile(x, y, min_zoom)
    required_tiles = list(all_descendant_tiles(x, y, min_zoom, max_zoom))
    required_tiles += [root_tile]
    return required_tiles


def verify_redundant_tiles(mbtiles_file, x, y, min_zoom, max_zoom, scheme):
    mbtiles = MBTiles(mbtiles_file, scheme)
    required_tiles = list_required_tiles(x, y, min_zoom, max_zoom)
    for tile in redundant_tiles(mbtiles, required_tiles):
        print('{}/{}/{}\t{}'.format(tile.z, tile.x, tile.y, 'REDUNDANT'))


def verify_missing_tiles(mbtiles_file, x, y, min_zoom, max_zoom, scheme):
    mbtiles = MBTiles(mbtiles_file, scheme)
    required_tiles = list_required_tiles(x, y, min_zoom, max_zoom)

    for tile in missing_tiles(mbtiles, required_tiles):
        print('{}/{}/{}\t{}'.format(tile.z, tile.x, tile.y, 'MISSING'))


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')
    if args.get('redundant'):
        verify_redundant_tiles(
            args['<mbtiles_file>'],
            int(args['<x>']),
            int(args['<y>']),
            int(args['-z']),
            int(args['-Z']),
            args['--scheme']
        )

    if args.get('missing'):
        verify_missing_tiles(
            args['<mbtiles_file>'],
            int(args['<x>']),
            int(args['<y>']),
            int(args['-z']),
            int(args['-Z']),
            args['--scheme']
        )

    if args.get('size'):
        verify_size(
            args['<mbtiles_file>'],
            int(args['-s']),
            args['--scheme']
        )

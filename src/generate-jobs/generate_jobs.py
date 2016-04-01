#!/usr/bin/env python
"""Generate jobs for rendering tiles in pyramid and list format in JSON format

Usage:
  generate_jobs.py pyramid <x> <y> <z> --job-zoom=<job-zoom>
  generate_jobs.py list <list_file> --batch-size=<batch_size>
  generate_jobs.py (-h | --help)
  generate_jobs.py --version

Options:
  -h --help                    Show this screen.
  --version                    Show version.
  --job-zoom=<job-zoom>        Max zoom level for pyramid jobs.
  --batch-size=<batch_size>    Amount of tiles for list jobs.
"""

import json
import hashlib
import mercantile
from docopt import docopt


def all_descendant_tiles(x, y, zoom, max_zoom):
    """
    Return all child tiles contained within a tile defined by x, y, zoom
    down to the max_zom level.
    """
    if zoom < max_zoom:
        for child_tile in mercantile.children(x, y, zoom):
            yield child_tile
            yield from all_descendant_tiles(child_tile.x, child_tile.y,
                                            child_tile.z, max_zoom)


def create_list_batch_job(tile_list):
    def payload_id():
        hash_obj = json.dumps(tile_list, sort_keys=True).encode('utf-8')
        return hashlib.sha1(hash_obj).hexdigest()

    return {
        'id': payload_id(),
        'type': 'list',
        'tiles':  tile_list
    }


def create_pyramid_job(x, y, min_zoom, max_zoom, bounds):
    pyramid = {
        'tile': {
            'x': x,
            'y': y,
            'min_zoom': z,
            'max_zoom': max_zoom
        },
        'bounds': {
            'west': bounds.west,
            'south': bounds.south,
            'east': bounds.east,
            'north': bounds.north
        }
    }

    def payload_id():
        hash_obj = json.dumps(pyramid, sort_keys=True).encode('utf-8')
        return hashlib.sha1(hash_obj).hexdigest()

    return {
        'id': payload_id(),
        'type': 'pyramid',
        'pyramid': pyramid
    }


def split_tiles_into_batch_jobs(tiles, batch_size):
    """
    Split list of tiles into batch jobs containing the
    instruction to render a list of tiles with the size of batch_size
    """
    tiles_batch = []

    for tile in tiles:
        tiles_batch.append(tile)
        if len(tiles_batch) > batch_size:
            yield create_list_batch_job(tiles_batch)
            tiles_batch = []

    yield create_list_batch_job(tiles_batch)


def pyramid_jobs(x, y, z, job_zoom):
    """
    Generate pyramid jobs for a given job_zoom level
    starting at with the parent tile defined by x, y, z.
    """
    if z == job_zoom:
        bounds = mercantile.bounds(x, y, z)
        yield create_pyramid_job(
            x=x, y=y,
            min_zoom=z, max_zoom=14,
            bounds=bounds
        )
        return

    tiles = all_descendant_tiles(x, y, z, job_zoom)
    pyramid_zoom_level_tiles = (t for t in tiles if t.z == job_zoom)

    for tile in pyramid_zoom_level_tiles:
        bounds = mercantile.bounds(tile.x, tile.y, tile.z)
        yield create_pyramid_job(tile.x, tile.y, min_zoom=tile.z,
                                 max_zoom=14, bounds=bounds)


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')

    if args['pyramid']:
        job_zoom = int(args['--job-zoom'])

        x = int(args['<x>'])
        y = int(args['<y>'])
        z = int(args['<z>'])

        for job in pyramid_jobs(x, y, z, job_zoom):
            print(json.dumps(job), flush=True)

    if args['list']:
        batch_size = int(args['--batch-size'])

        def convert_line_to_tile(line):
            z, x, y = line.split('/')
            return {
                'x': int(x),
                'y': int(y),
                'z': int(z)
            }

        with open(args['<list_file>'], "r") as file_handle:
            tiles = [convert_line_to_tile(l) for l in file_handle]

            # Sorting the tiles should result in besser job
            # locality when dividing it into batches
            tiles.sort(key=lambda t: (t['z'], t['x'], t['y']))

            for job in split_tiles_into_batch_jobs(tiles, batch_size):
                print(json.dumps(job), flush=True)

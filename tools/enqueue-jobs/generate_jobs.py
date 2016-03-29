#!/usr/bin/env python
"""Generate jobs for rendering tiles in pyramid and list format in JSON format

Usage:
  generate_jobs.py pyramid <x> <y> <z> --max-zoom=<max-zoom>
  generate_jobs.py list <list_file> --batch-size=<batch_size>
  generate_jobs.py (-h | --help)
  generate_jobs.py --version

Options:
  -h --help                    Show this screen.
  --version                    Show version.
  --max-zoom=<max-zoom>        Max zoom level for pyramid jobs.
  --batch-size=<batch_size>    Amount of tiles for list jobs.
"""

import os
import json

import mercantile
import boto.sqs
from boto.sqs.message import Message
from docopt import docopt


def all_descendant_tiles(x, y, zoom, max_zoom):
    """Return all subtiles contained within a tile"""
    if zoom < max_zoom:
        for child_tile in mercantile.children(x, y, zoom):
            yield child_tile
            yield from all_descendant_tiles(child_tile.x, child_tile.y,
                                            child_tile.z, max_zoom)


def tiles_for_zoom_level(zoom_level):
    tiles = all_descendant_tiles(x=0, y=0, zoom=0, max_zoom=zoom_level)

    for tile in tiles:
        if tile.z == zoom_level:
            yield tile


def connect_job_queue():
    conn = boto.sqs.connect_to_region(os.getenv('AWS_REGION', 'eu-central-1'))
    queue_name = os.getenv('QUEUE_NAME', 'osm2vectortiles_jobs')
    queue = conn.get_queue(queue_name)
    if queue is None:
        raise ValueError('Could not connect to queue {}'.format(queue_name))

    return queue


def create_list_batch_job(tile_list):
    return {
        'type': 'list',
        'tiles':  tile_list
    }


def create_pyramid_job(x, y, min_zoom, max_zoom, bounds):
    return {
        'x': tile.x,
        'y': tile.y,
        'type': 'pyramid',
        'min_zoom': tile.z,
        'max_zoom': 14,
        'bounds': {
            'west': bounds.west,
            'south': bounds.south,
            'east': bounds.east,
            'north': bounds.north
        }
    }


def split_tiles_into_batch_jobs(tiles):
    tiles_batch = []

    for line in file_handle:
        tiles_batch.append(line)
        if len(job_list) > batch_size:
            yield create_list_batch_job(tiles_batch)
            tiles_batch = []

    yield create_list_batch_job(tiles_batch)


def pyramid_jobs(x, y, z, max_zoom)
        tiles = all_descendant_tiles(x=x, y=y, zoom=0, max_zoom=zoom_level)
        pyramid_zoom_level_tiles = (t for t in tiles if t.z == zoom_level)

        for tile in pyramid_zoom_level_tiles:
            bounds = mercantile.bounds(tile.x, tile.y, tile.z)
            yield create_pyramid_job(tile.x, tile.y, min_zoom=0,
                                     max_zoom=tile.z, bounds=bounds)

if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')

    if  args['pyramid']:
        zoom_level = int(args['<max-zoom>'])

        x = int(args['<x>'])
        y = int(args['<y>'])
        z = int(args['<z>'])

        for job in pyramid_jobs(x, y, z, zoom_level):
            print(job)

    if  args['list']:
        batch_size = int(args['<batch_size>'])

        tiles = []
        with open(args['list_file'],"r") as file_handle:
            for line in file_handle:
                tiles.append(line)

        for job in split_tiles_into_batch_jobs(tiles):
            print(job)



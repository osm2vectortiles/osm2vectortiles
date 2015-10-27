#!/usr/bin/env python

import os
import json

import mercantile
import boto.sqs
from boto.sqs.message import Message

from water import in_water


def all_descendant_tiles(x, y, zoom, max_zoom):
    """Return all subtiles contained within a tile"""
    if zoom < max_zoom:
        for child_tile in mercantile.children(x, y, zoom):
            yield child_tile
            yield from all_descendant_tiles(child_tile.x, child_tile.y,
                                            child_tile.z, max_zoom)

def tiles_for_zoom_level(zoom_level):
    # Only switzerland for now
    tiles = all_descendant_tiles(x=33, y=22, zoom=6, max_zoom=zoom_level)

    for tile in tiles:
        if tile.z == zoom_level and not in_water(tile.x, tile.y, tile.z):
            yield tile


def connect_job_queue():
    conn = boto.sqs.connect_to_region(
        region_name=os.getenv('AWS_REGION', 'eu-central-1'),
    )
    queue_name = os.getenv('QUEUE_NAME', 'osm2vectortiles_jobs')
    queue = conn.get_queue(queue_name)
    return queue


def create_job(x, y, min_zoom, max_zoom, bounds):
    body = {
        'x': tile.x,
        'y': tile.y,
        'min_zoom': tile.z,
        'max_zoom': 14,
        'bounds': {
            'west': bounds.west,
            'south': bounds.south,
            'east': bounds.east,
            'north': bounds.north
        }
    }

    msg = Message()
    msg.set_body(json.dumps(body))
    return msg


if __name__ == '__main__':
    queue = connect_job_queue()
    zoom_level = int(os.getenv('TASK_ZOOM_LEVEL', '8'))

    for tile in tiles_for_zoom_level(zoom_level):
        bounds = mercantile.bounds(tile.x, tile.y, tile.z)

        job = create_job(tile.x, tile.y, min_zoom=0,
                         max_zoom=tile.z, bounds=bounds)
        queue.write(job)

        print("{} {} {} {}".format(
            bounds.west, bounds.south,
            bounds.east, bounds.north
        ))

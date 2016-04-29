#!/usr/bin/env python
"""Generate jobs for rendering tiles in pyramid and list format in JSON format

Usage:
  create_extracts.py <source_file> <tsv_file> [--concurrency=<concurrency>] [--target-dir=<target-dir>]
  create_extracts.py (-h | --help)
  create_extracts.py --version

Options:
  -h --help                     Show this screen.
  --version                     Show version.
  --concurrency=<concurrency>   Number of copy processes to use [default: 2].
  --target-dir=<target-dir>     Target directory to put extracts in [default: ./]
"""

import json
import subprocess
import mbutil
import csv
import os.path
from collections import namedtuple
from docopt import docopt

ATTRIBUTION = '<a href="http://www.openstreetmap.org/about/" target="_blank">&copy; OpenStreetMap contributors</a>'
VERSION = '1.5'


class Extract(object):

    def __init__(self, extract, country, city, top, left, bottom, right):
        self.extract = extract
        self.country = country
        self.city = city

        self.min_lon = left
        self.min_lat = bottom
        self.max_lon = right
        self.max_lat = top

        self.min_zoom = 0
        self.max_zoom = 14
        self.center_zoom = 10

    def bounds(self):
        return '{},{},{},{}'.format(self.min_lon, self.min_lat,
                                    self.max_lon, self.max_lat)

    def center(self):
        center_lon = (self.min_lon + self.max_lon) / 2.0
        center_lat = (self.min_lat + self.max_lat) / 2.0
        return '{},{},{}'.format(center_lat, center_lon, self.center_zoom)

    def metadata(self, extract_file):
        return {
            "type": "baselayer",
            "attribution": ATTRIBUTION,
            "version": VERSION,
            "minzoom": self.min_zoom,
            "maxzoom": self.max_zoom,
            "name": "osm2vectortiles",
            "id": "osm2vectortiles",
            "description": "Extract from http://osm2vectortiles.org",
            "bounds": self.bounds(),
            "center": self.center(),
            "basename": os.path.basename(extract_file),
            "filesize": os.path.getsize(extract_file)
        }


def create_extract(extract, source_file, extract_file):
    source = 'mbtiles://' + os.path.abspath(source_file)
    sink = 'mbtiles://' + os.path.abspath(extract_file)

    print('Bounds: {}'.format(extract.bounds()))
    cmd = [
        'tilelive-copy',
        '--concurrency', '20',
        '--bounds={}'.format(extract.bounds()),
        '--minzoom', str(extract.min_zoom),
        '--maxzoom', str(extract.max_zoom),
        source, sink
    ]

    subprocess.check_call(cmd)


def update_metadata(mbtiles_file, metadata):
    """
    Update metadata key value pairs inside the MBTiles file
    with the provided metadata
    """
    conn = mbutil.mbtiles_connect(mbtiles_file)

    def upsert_entry(key, value):
        conn.execute("DELETE FROM metadata WHERE name='{}'".format(key))
        conn.execute("INSERT INTO metadata VALUES('{}', '{}')".format(key, value))

    for key, value in metadata.items():
        upsert_entry(key, value)


def patch_mbtiles(source_file, target_file):
    conn = mbutil.mbtiles_connect(target_file)
    conn.execute(
        """
        PRAGMA journal_mode=PERSIST;
        PRAGMA page_size=80000;
        PRAGMA synchronous=OFF;
        ATTACH DATABASE '{}' AS source;
        REPLACE INTO map SELECT * FROM source.map;
        REPLACE INTO images SELECT * FROM source.images;"
        """.format(source_file)
    )


def parse_extracts(tsv_file):
    with open(args['<tsv_file>'], "r") as file_handle:
        reader = csv.DictReader(file_handle, delimiter='\t', )
        for row in reader:
            yield Extract(
                row['extract'],
                row['country'],
                row['city'],
                float(row['top']),
                float(row['left']),
                float(row['bottom']),
                float(row['right'])
            )


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')

    #
    process_count = int(args['--concurrency'])
    target_dir = args['--target-dir']
    source_file = args['<source_file>']
    extracts = list(parse_extracts(args['<tsv_file>']))

    for extract in extracts:
        extract_file = os.path.join(target_dir, extract.extract + '.mbtiles')

        print('Create extract {}'.format(extract_file))
        create_extract(extract, source_file, extract_file)
        print('Update metadata {}'.format(extract_file))
        update_metadata(extract_file, extract.metadata(extract_file))


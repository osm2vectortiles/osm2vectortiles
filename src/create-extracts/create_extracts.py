#!/usr/bin/env python
"""Generate jobs for rendering tiles in pyramid and list format in JSON format

Usage:
  create_extracts.py bbox <source_file> <tsv_file> [--patch-from=<patch-src>]  [--upload] [--concurrency=<concurrency>] [--target-dir=<target-dir>]
  create_extracts.py zoom-level <source_file> --max-zoom=<max-zoom> [--upload] [--target-dir=<target-dir>]
  create_extracts.py (-h | --help)
  create_extracts.py --version

Options:
  -h --help                     Show this screen.
  --version                     Show version.
  --upload                      Upload extracts to S3.
  --patch-from=<patch-src>      Patch MBTiles file with other MBTiles src.
  --concurrency=<concurrency>   Number of copy processes to use [default: 4].
  --max-zoom=<max-zoom>         Max zoom level of low zoom level extract.
  --target-dir=<target-dir>     Target directory to put extracts in [default: ./]
"""

import shutil
import subprocess
import sqlite3
import csv
import os.path
from multiprocessing.dummy import Pool as ProcessPool
from docopt import docopt

ATTRIBUTION = '<a href="http://www.openstreetmap.org/about/" target="_blank">&copy; OpenStreetMap contributors</a>'
VERSION = '2.0'


class Extract(object):

    def __init__(self, extract, country, city, top, left, bottom, right,
                 min_zoom=0, max_zoom=14, center_zoom=10):
        self.extract = extract
        self.country = country
        self.city = city

        self.min_lon = left
        self.min_lat = bottom
        self.max_lon = right
        self.max_lat = top

        self.min_zoom = min_zoom
        self.max_zoom = max_zoom
        self.center_zoom = center_zoom

    def bounds(self):
        return '{},{},{},{}'.format(self.min_lon, self.min_lat,
                                    self.max_lon, self.max_lat)

    def center(self):
        center_lon = (self.min_lon + self.max_lon) / 2.0
        center_lat = (self.min_lat + self.max_lat) / 2.0
        return '{},{},{}'.format(center_lon, center_lat, self.center_zoom)

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
        '--bounds={}'.format(extract.bounds()),
        '--minzoom', str(extract.min_zoom),
        '--maxzoom', str(extract.max_zoom),
        '--timeout=200000',
        source, sink
    ]

    subprocess.check_call(cmd)


def update_metadata(mbtiles_file, metadata):
    """
    Update metadata key value pairs inside the MBTiles file
    with the provided metadata
    """
    conn = sqlite3.connect(mbtiles_file)

    def upsert_entry(key, value):
        conn.execute("DELETE FROM metadata WHERE name='{}'".format(key))
        conn.execute("INSERT INTO metadata VALUES('{}', '{}')".format(key, value))

    for key, value in metadata.items():
        upsert_entry(key, value)

    conn.commit()
    conn.close()


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


def upload_mbtiles(mbtiles_file):
    """
    Use s3cmd to upload file. This is easier than using Boto directly.
    The upload command is configured via environment variables and not
    the extract utility command line flags.
    """
    config_file = os.getenv('S3_CONFIG_FILE',
                            os.path.join(os.environ['HOME'], '.s3cfg'))
    access_key = os.environ['S3_ACCESS_KEY']
    secret_key = os.environ['S3_SECRET_KEY']
    bucket_name = os.getenv('S3_BUCKET_NAME', 'osm2vectortiles-downloads')
    prefix = os.getenv('S3_PREFIX', 'v{}/{}/'.format(VERSION, 'extracts'))

    subprocess.check_call([
        's3cmd',
        '--config={}'.format(config_file),
        '--access_key={}'.format(access_key),
        '--secret_key={}'.format(secret_key),
        'put', mbtiles_file,
        's3://{}/{}'.format(bucket_name, prefix),
        '--acl-public',
        '--multipart-chunk-size-mb=50'
    ])


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')

    target_dir = args['--target-dir']
    upload = args['--upload']
    source_file = args['<source_file>']

    def process_extract(extract):

        extract_file = os.path.join(target_dir, extract.extract + '.mbtiles')
        print('Create extract {}'.format(extract_file))

        # Instead of patching copy over the patch source as target and
        # write directly to it (since that works concurrently).
        patch_src = args['--patch-from']
        if patch_src:
            print('Use patch from {} as base'.format(patch_src))
            shutil.copyfile(patch_src, extract_file)

        create_extract(extract, source_file, extract_file)
        print('Update metadata {}'.format(extract_file))
        update_metadata(extract_file, extract.metadata(extract_file))

        if upload:
            print('Upload file {}'.format(extract_file))
            upload_mbtiles(extract_file)

    if args['bbox']:
        process_count = int(args['--concurrency'])
        extracts = list(parse_extracts(args['<tsv_file>']))
        pool = ProcessPool(process_count)
        pool.map(process_extract, extracts)
        pool.close()
        pool.join()

    if args['zoom-level']:
        max_zoom_level = int(args['--max-zoom'])
        extract = Extract('world_z0-z{}'.format(max_zoom_level),
                          country=None,
                          city=None,
                          left=-180,
                          right=180,
                          top=85.0511,
                          bottom=-85.0511,
                          center_zoom=2,
                          min_zoom=0,
                          max_zoom=max_zoom_level
                         )
        process_extract(extract)

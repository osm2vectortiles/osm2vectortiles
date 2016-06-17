#!/usr/bin/env python
""""
Integration test for entire OSM2VectorTiles workflow.
Primary purpose is to verify that everything works together
not to verify correctness.
"""

import os
import time
import subprocess
import pytest
from mbtoolbox.verify import list_required_tiles, missing_tiles
from mbtoolbox.mbtiles import MBTiles

PARENT_PROJECT_DIR = os.path.join(os.path.realpath(__file__), '../../../')
PROJECT_DIR = os.path.abspath(os.getenv('PROJECT_DIR', PARENT_PROJECT_DIR))
ALBANIA_BBOX = '19.6875,40.97989806962015,20.390625,41.50857729743933'
ALBANIA_TIRANA_TILE = (284, 191, 9)

BUCKET = os.getenv('BUCKET', 'osm2vectortiles-testing')
AWS_S3_HOST = os.getenv('AWS_S3_HOST', 'os.zhdk.cloud.switch.ch')
AWS_SECRET_ACCESS_KEY = os.environ['AWS_SECRET_ACCESS_KEY']
AWS_ACCESS_KEY_ID = os.environ['AWS_ACCESS_KEY_ID']


class DockerCompose(object):
    def __init__(self, project_dir=PROJECT_DIR):
        self.project_dir = project_dir

    def compose(self, args):
        subprocess.check_call(['docker-compose'] + args, cwd=self.project_dir)

    def run(self, args):
        self.compose(['run'] + args)

    def scale(self, container, count):
        self.compose(['scale', '{}={}'.format(container, count)])

    def up(self, container):
        self.compose(['up', '-d', container])

    def stop(self, container):
        self.compose(['stop', container])

    def remove_all(self):
        self.compose(['stop'])
        self.compose(['rm', '-v', '--force'])


@pytest.mark.run(order=1)
def test_postgis_startup():
    print(PROJECT_DIR)
    dc = DockerCompose()
    dc.remove_all()
    dc.up('postgis')
    # PostGIS can take a long time to get ready
    time.sleep(10)


@pytest.mark.run(order=2)
def test_import_external():
    dc = DockerCompose()
    dc.run(['import-external'])


@pytest.mark.run(order=3)
def test_import_osm():
    dc = DockerCompose()
    dc.run(['import-osm'])


@pytest.mark.run(order=4)
def test_import_sql():
    dc = DockerCompose()
    dc.run(['import-sql'])


@pytest.mark.run(order=5)
def test_local_export():
    "Test export of local Liechtenstein bbox and verify all tiles are present"
    dc = DockerCompose()

    def export_bbox(bbox, min_zoom, max_zoom):
        dc.run([
            '-e', 'BBOX={}'.format(bbox),
            '-e', 'MIN_ZOOM={}'.format(min_zoom),
            '-e', 'MAX_ZOOM={}'.format(max_zoom),
            'export'
        ])

    tile_x, tile_y, tile_z = ALBANIA_TIRANA_TILE
    export_bbox(ALBANIA_BBOX, tile_z, 14)

    # There are missing tiles on z14 because
    # Albania does not have data at some places
    exported_mbtiles = os.path.join(PROJECT_DIR, 'export/tiles.mbtiles')
    tiles = find_missing_tiles(exported_mbtiles, tile_x, tile_y, tile_z, 13)
    assert tiles == []


def find_missing_tiles(mbtiles_file, x, y, min_z, max_z):
    mbtiles = MBTiles(mbtiles_file, 'tms')
    required_tiles = list_required_tiles(x, y, min_z, max_z)
    return list(missing_tiles(mbtiles, required_tiles))


@pytest.mark.run(order=6)
def test_distributed_worker():
    dc = DockerCompose()

    def schedule_tile_jobs(x, y, z, job_zoom):
        dc.run([
            '-e', 'TILE_X={}'.format(x),
            '-e', 'TILE_Y={}'.format(y),
            '-e', 'TILE_Z={}'.format(z),
            '-e', 'JOB_ZOOM={}'.format(job_zoom),
            'generate-jobs'
        ])

    dc.up('rabbitmq')
    time.sleep(10)

    tile_x, tile_y, tile_z = ALBANIA_TIRANA_TILE
    job_zoom = tile_z + 1
    schedule_tile_jobs(tile_x, tile_y, tile_z, job_zoom)

    dc.run([
        '-e', 'BUCKET_NAME={}'.format(BUCKET),
        '-e', 'AWS_ACCESS_KEY_ID={}'.format(AWS_ACCESS_KEY_ID),
        '-e', 'AWS_SECRET_ACCESS_KEY={}'.format(AWS_SECRET_ACCESS_KEY),
        '-e', 'AWS_S3_HOST={}'.format(AWS_S3_HOST),
        'export-worker'
    ])

    # Give time to merge jobs together
    dc.up('merge-jobs')
    time.sleep(20)
    dc.stop('merge-jobs')

    # Merge jobs will merge all results into the existing planet.mbtiles
    # if MBTiles contains all the Albania tiles at job zoom level
    # the export was successful
    exported_mbtiles = os.path.join(PROJECT_DIR, 'export/planet.mbtiles')
    print('Checking {} for missing tiles'.format(exported_mbtiles))
    tiles = find_missing_tiles(exported_mbtiles, tile_x, tile_y, tile_z, 13)
    assert [t for t in tiles if t.z > tile_z] == []


@pytest.mark.run(order=7)
def test_diff_update():
    dc = DockerCompose()

    # Pull the latest diffs
    baseurl = 'http://download.geofabrik.de/europe/albania-updates/'
    dc.run(['-e', 'OSM_UPDATE_BASEURL={}'.format(baseurl), 'update-osm-diff'])

    # Import diffs and calculate the changed tiles
    dc.run(['import-osm-diff'])
    dc.run(['changed-tiles'])

    # Read and verify that at least one tile is marked dirty
    tile_file = os.path.join(PROJECT_DIR, 'export/tiles.txt')
    print('Checking {} for changed tiles'.format(tile_file))
    num_lines = sum(1 for line in open(tile_file))
    assert num_lines > 0


@pytest.mark.run(order=8)
def test_diff_jobs():
    dc = DockerCompose()

    # Schedule changed tiles as jobs
    dc.run(['generate-diff-jobs'])

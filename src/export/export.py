#!/usr/bin/env python
"""Wrapper around tilelive for exporting vector tiles from tm2source.

Usage:
  export.py local <mbtiles_file> --tm2source=<tm2source> [--bbox=<bbox>] [--min_zoom=<min_zoom>] [--max_zoom=<max_zoom>] [--render_scheme=<scheme>]
  export.py remote <sqs_queue> --tm2source=<tm2source> [--bucket=<bucket>] [--render_scheme=<scheme>]
  export.py (-h | --help)
  export.py --version

Options:
  -h --help                 Show this screen.
  --version                 Show version.
  --bbox=<bbox>             WGS84 bounding box [default: -180, -85.0511, 180, 85.0511].
  --min_zoom=<min_zoom>     Minimum zoom [default: 8].
  --max_zoom=<max_zoom>     Maximum zoom  [default: 12].
  --render_scheme=<scheme>  Either pyramid or scanline [default: pyramid]
  --tm2source=<tm2source>   Directory of tm2source
  --bucket=<bucket>         S3 Bucket name for storing results [default: osm2vectortiles-jobs]

"""
import watchtower
import socket
import time
import logging
import subprocess
import re
import os
import os.path
import json

import boto.sqs
from docopt import docopt


logging.basicConfig(level=logging.INFO)
mapnik_logger = logging.getLogger("mapnik")
export_logger = logging.getLogger("export")


def local_ip():
    return socket.gethostbyname(socket.gethostname())


def create_tilelive_command(tm2source, mbtiles_file, bbox,
                            min_zoom=8, max_zoom=12, scheme='pyramid'):
    tilelive_binary = os.getenv('TILELIVE_BIN', 'tl')
    source = 'tmsource://' + os.path.abspath(tm2source)
    sink = 'mbtiles://' + os.path.abspath(mbtiles_file)

    cmd = [
        tilelive_binary, 'copy',
        '-s', 'pyramid',
        '-b', bbox,
        '--min-zoom', str(min_zoom),
        '--max-zoom', str(max_zoom),
        source, sink
    ]

    return cmd


def export_local(tilelive_command, logging_info):
    subprocess.check_output(
        tilelive_command,
        stderr=subprocess.STDOUT,
    )


def connect_job_queue(queue_name):
    conn = boto.sqs.connect_to_region(os.getenv('AWS_REGION', 'eu-central-1'))
    queue = conn.get_queue(queue_name)
    if queue is None:
        raise ValueError('Could not connect to queue {}'.format(queue_name))
    return queue


def connect_s3(bucket_name):
    conn = boto.s3.connect_to_region(os.getenv('AWS_REGION', 'eu-central-1'))
    return conn.get_bucket(bucket_name)


def upload_mbtiles(bucket, mbtiles_file):
    keyname = os.path.basename(mbtiles_file)
    obj = bucket.new_key(keyname)
    obj.set_contents_from_filename(mbtiles_file)


def export_remote(tm2source, sqs_queue, render_scheme, bucket_name):
    bucket = connect_s3(bucket_name)
    queue = connect_job_queue(sqs_queue)
    timeout = int(os.getenv('JOB_TIMEOUT', 15 * 60))

    def complete_job(task_id, body, logging_info):
        mbtiles_file = task_id + '.mbtiles'
        bounds = body['bounds']
        bbox = '{} {} {} {}'.format(
            bounds['west'], bounds['south'],
            bounds['east'], bounds['north']
        )

        tilelive_command = create_tilelive_command(
            tm2source,
            mbtiles_file,
            bbox,
            body['min_zoom'],
            body['max_zoom'],
            render_scheme
        )

        start = time.time()
        export_local(tilelive_command, logging_info)
        end = time.time()

        export_logger.info('Elapsed time: {}'.format(int(end - start)),
                           extra=logging_info)
        upload_mbtiles(bucket, mbtiles_file)
        os.remove(mbtiles_file)
        export_logger.info('Upload mbtiles {}'.format(mbtiles_file),
                           extra=logging_info)

        queue.delete_message(message)

    while True:
        message = queue.read(visibility_timeout=timeout)
        if message:
            body = json.loads(message.get_body())
            task_id = '{}_{}_z{}-z{}'.format(
                body['x'],
                body['y'],
                body['min_zoom'],
                body['max_zoom']
            )
            logging_info = {
                'ip': local_ip(),
                'task_id':  task_id
            }
            try:
                complete_job(task_id, body, logging_info)
            except subprocess.CalledProcessError as err:
                export_logger.exception('Could not complete job: ' + err.output,
                                        exc_info=True, extra=logging_info)
            except Exception:
                export_logger.exception('Could not complete job',
                                        exc_info=True, extra=logging_info)
        else:
            print('No jobs to read')
            break


def main(args):
    if args.get('local'):
        tilelive_command = create_tilelive_command(
            args['--tm2source'],
            args['<mbtiles_file>'],
            args['--bbox'],
            args['--min_zoom'],
            args['--max_zoom'],
            args['--render_scheme']
        )
        export_local(tilelive_command, {})

    if args.get('remote'):
        formatter = logging.Formatter('%(ip)s %(task_id)s %(message)s')
        handler = watchtower.CloudWatchLogHandler()
        handler.setFormatter(formatter)

        mapnik_logger.addHandler(handler)
        export_logger.addHandler(handler)

        export_remote(
            args['--tm2source'],
            args['<sqs_queue>'],
            args['--render_scheme'],
            args['--bucket'],
        )


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')
    main(args)

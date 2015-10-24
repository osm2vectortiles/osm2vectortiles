#!/usr/bin/env python
"""Export vector tiles from OpenStreetMap

Usage:
  export.py local <mbtiles_file> --tm2source=<tm2source> [--bbox=<bbox>] [--min_zoom=<min_zoom>] [--max_zoom=<max_zoom>] [--render_scheme=<scheme>]
  export.py remote <sqs_queue> --tm2source=<tm2source> [--render_scheme=<scheme>]
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
"""
import subprocess
import os
import os.path
import json

import boto.sqs
from docopt import docopt


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


def export_local(tilelive_command):
    print(tilelive_command)
    proc = subprocess.Popen(
        tilelive_command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        bufsize=0,
        universal_newlines=True
    )
    for line in iter(proc.stdout.readline, ''):
        print line.rstrip()

    proc.wait()
    if proc.returncode != 0:
        raise subprocess.CalledProcessError(returncode=proc.returncode,
                                            cmd=tilelive_command)


def connect_job_queue(queue_name):
    conn = boto.sqs.connect_to_region(
        region_name=os.getenv('AWS_REGION', 'eu-central-1'),
        aws_access_key_id=os.environ['AWS_ACCESS_KEY'],
        aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY']
    )
    queue = conn.get_queue(queue_name)
    return queue


def export_remote(tm2source, sqs_queue, render_scheme):
    timeout = int(os.getenv('JOB_TIMEOUT', 15 * 60))
    queue = connect_job_queue(sqs_queue)

    while True:
        message = queue.read(visibility_timeout=timeout)
        print(message)
        if message:
            body = json.loads(message.get_body())
            print(body)

            bounds = body['bounds']
            bbox = '{} {} {} {}'.format(
                bounds[0][0], bounds[0][1],
                bounds[1][0], bounds[1][1]
            )
            mbtiles_file = '{}_{}.mbtiles'.format(body['x'], body['y'])

            tilelive_command = create_tilelive_command(
                tm2source,
                mbtiles_file,
                bbox,
                body['min_zoom'],
                body['max_zoom'],
                render_scheme
            )
            export_local(tilelive_command)
            print("Executed job and exportet to " + mbtiles_file)
            queue.delete_message(message)


if __name__ == '__main__':
    arguments = docopt(__doc__, version='0.1')
    print(arguments)
    if arguments.get('local'):
        tilelive_command = create_tilelive_command(
            arguments['--tm2source'],
            arguments['<mbtiles_file>'],
            arguments['--bbox'],
            arguments['--min_zoom'],
            arguments['--max_zoom'],
            arguments['--render_scheme']
        )
        export_local(tilelive_command)

    if arguments.get('remote'):
        export_remote(
            arguments['--tm2source'],
            arguments['<sqs_queue>'],
            arguments['--render_scheme']
        )

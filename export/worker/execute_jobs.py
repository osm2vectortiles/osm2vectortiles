#!/usr/bin/env python

import os
import json
import subprocess

import boto.sqs


def connect_job_queue():
    conn = boto.sqs.connect_to_region(
        region_name=os.getenv('AWS_REGION', 'eu-central-1'),
        aws_access_key_id=os.getenv('AWS_ACCESS_KEY', ''),
        aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY', '')
    )
    queue_name = os.getenv('QUEUE_NAME', 'osm2vectortiles_jobs')
    queue = conn.get_queue(queue_name)
    return queue


def execute_job(x, y, min_zoom, max_zoom, bounds):
    source = os.environ['SOURCE']
    sink = os.environ['SINK']
    mbtiles_path = os.environ['MBTILES_PATH']

    bbox = '{} {} {} {}'.format(
        bounds[0][0], bounds[0][1],
        bounds[1][0], bounds[1][1]
    )

    cmd = [
        'tl', 'copy',
        '-s', 'pyramid',
        '-b', bbox,
        '--min-zoom', str(min_zoom),
        '--max-zoom', str(max_zoom),
        source, sink
    ]

    print(cmd)
    subprocess.check_call(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return mbtiles_path


if __name__ == '__main__':
    queue = connect_job_queue()

    while True:
        message = queue.read(visibility_timeout=15 * 60)
        print(message)
        if message:
            body = json.loads(message.get_body())
            print(body)

            bounds = body['bounds']
            print('{} {} {} {}'.format(
                bounds[0][0], bounds[0][1],
                bounds[1][0], bounds[1][1]
            ))

            result = execute_job(
                body['x'],
                body['y'],
                body['min_zoom'],
                body['max_zoom'],
                bounds
            )
            print("Executed job " + result)
            queue.delete_message(message)

#!/usr/bin/env python
"""Wrapper around tilelive-copy for exporting vector tiles from tm2source.

Usage:
  export_remote.py <rabbitmq_url> --tm2source=<tm2source> [--job-queue=<job-queue>] [--bucket=<bucket>] [--render_scheme=<scheme>]
  export_remote.py (-h | --help)
  export_remote.py --version

Options:
  -h --help                 Show this screen.
  --version                 Show version.
  --render_scheme=<scheme>  Either pyramid or scanline [default: pyramid]
  --job-queue=<job-queue>   Job queue name [default: jobs]
  --tm2source=<tm2source>   Directory of tm2source
  --bucket=<bucket>         S3 Bucket name for storing results [default: osm2vectortiles-jobs]

"""
import time
import subprocess
import os
import os.path
import json
import humanize

from boto.s3.connection import S3Connection, OrdinaryCallingFormat
from mbtoolbox.optimize import remove_subpyramids

import pika
from docopt import docopt


def s3_url(host, port, bucket_name, file_name):
    protocol = 'https' if port == 443 else 'http'
    return '{}://{}:{}/{}/{}'.format(
        protocol, host, port,
        bucket_name, file_name
    )


def connect_s3(host, port, bucket_name):
    # import boto
    # boto.set_stream_logger('paws')
    is_secure = port == 443
    conn = S3Connection(
        os.getenv('AWS_ACCESS_KEY_ID', 'dummy'),
        os.getenv('AWS_SECRET_ACCESS_KEY', 'dummy'),
        is_secure=is_secure,
        port=port,
        host=host,
        calling_format=OrdinaryCallingFormat()
    )

    conn.create_bucket(bucket_name)
    return conn.get_bucket(bucket_name)


def upload_mbtiles(bucket, mbtiles_file):
    """Upload mbtiles file to a bucket with the filename as S3 key"""
    keyname = os.path.basename(mbtiles_file)
    obj = bucket.new_key(keyname)
    obj.set_contents_from_filename(mbtiles_file, replace=True)


def create_tilelive_bbox(bounds):
    return '{},{},{},{}'.format(
        bounds['west'], bounds['south'],
        bounds['east'], bounds['north']
    )


def create_result_message(task_id, download_link, original_job_msg):
    return {
        'id': task_id,
        'url': download_link,
        'job': original_job_msg
    }


def render_tile_list_command(source, sink, list_file):
    return [
        'tilelive-copy',
        '--scheme', 'list',
        '--list', list_file,
        source, sink
    ]


def render_pyramid_command(source, sink, bounds, min_zoom, max_zoom):
    return [
        'tilelive-copy',
        '--scheme', 'pyramid',
        '--minzoom', str(min_zoom),
        '--maxzoom', str(max_zoom),
        '--bounds={}'.format(bounds),
        source, sink
    ]


def optimize_mbtiles(mbtiles_file, mask_level=8):
    remove_subpyramids(mbtiles_file, mask_level, 'tms')


def export_remote(tm2source, rabbitmq_url, queue_name, result_queue_name,
                  render_scheme, bucket_name):
    host = os.getenv('AWS_S3_HOST', 'mock-s3')
    port = int(os.getenv('AWS_S3_PORT', 8080))

    bucket = connect_s3(host, port, bucket_name)

    connection = pika.BlockingConnection(pika.URLParameters(rabbitmq_url))
    channel = connection.channel()
    channel.basic_qos(prefetch_count=1)
    channel.confirm_delivery()
    configure_rabbitmq(channel)

    def callback(ch, method, properties, body):
        msg = json.loads(body.decode('utf-8'))
        task_id = msg['id']
        mbtiles_file = task_id + '.mbtiles'

        source = 'tmsource://' + os.path.abspath(tm2source)
        sink = 'mbtiles://' + os.path.abspath(mbtiles_file)
        tilelive_cmd = []

        if msg['type'] == 'pyramid':
            pyramid = msg['pyramid']
            tileinfo = pyramid['tile']

            tilelive_cmd = render_pyramid_command(
                source, sink,
                bounds=create_tilelive_bbox(pyramid['bounds']),
                min_zoom=tileinfo['min_zoom'],
                max_zoom=tileinfo['max_zoom']
            )
        elif msg['type'] == 'list':
            list_file = '/tmp/tiles.txt'
            with open(list_file, 'w') as fh:
                write_list_file(fh)

            tilelive_cmd = render_tile_list_command(
                source, sink,
                list_file=list_file,
            )
        else:
            raise ValueError("Message must be either of type pyramid or list")

        start = time.time()
        subprocess.check_call(tilelive_cmd)
        end = time.time()

        print('Rendering time: {}'.format(humanize.naturaltime(end - start)))

        print('Optimize MBTiles file size')
        optimize_mbtiles(mbtiles_file)
        upload_mbtiles(bucket, mbtiles_file)
        os.remove(mbtiles_file)

        print('Upload mbtiles {}'.format(mbtiles_file))

        download_link = s3_url(host, port, bucket_name, mbtiles_file)
        result_msg = create_result_message(task_id, download_link, msg)

        durable_publish(channel, result_queue_name,
                        body=json.dumps(result_msg))
        channel.basic_ack(delivery_tag=method.delivery_tag)


    channel.basic_consume(callback, queue=queue_name)
    try:
        channel.start_consuming()
    except KeyboardInterrupt:
        channel.stop_consuming()

    connection.close()


def configure_rabbitmq(channel):
    """Setup all queues and topics for RabbitMQ"""

    def queue_declare(queue):
        return channel.queue_declare(queue=queue, durable=True)

    queue_declare('jobs')
    queue_declare('results')


def durable_publish(channel, queue, body):
    """
    Publish a message body to a queue in a channel and ensure it stays
    durable on RabbitMQ server restart
    """
    properties = pika.BasicProperties(delivery_mode=2,
                                      content_type='application/json')
    channel.basic_publish(exchange='', routing_key=queue,
                          body=body, properties=properties)


def write_list_file(fh, tiles):
    for tile in tiles:
        fh.write('{}/{}/{}\n'.format(tile['z'], tile['x'], tile['y']))


def main(args):
    export_remote(
        args['--tm2source'],
        args['<rabbitmq_url>'],
        args['--job-queue'],
        'results',
        args['--render_scheme'],
        args['--bucket'],
    )


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')
    main(args)

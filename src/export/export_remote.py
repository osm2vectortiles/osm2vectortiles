#!/usr/bin/env python
"""Wrapper around tilelive for exporting vector tiles from tm2source.

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
import watchtower
import socket
import time
import logging
import subprocess
import re
import sys
import os
import os.path
import json

from boto.s3.connection import S3Connection, OrdinaryCallingFormat
import boto.sqs
import pika
from docopt import docopt


logging.basicConfig(level=logging.INFO)
mapnik_logger = logging.getLogger("mapnik")
export_logger = logging.getLogger("export")


def local_ip():
    return socket.gethostbyname(socket.gethostname())


def create_tilelive_command(tm2source, mbtiles_file, bbox,
                            min_zoom=8, max_zoom=12, scheme='pyramid'):
    tilelive_binary = os.getenv('TILELIVE_BIN', 'tilelive-copy')
    source = 'tmsource://' + os.path.abspath(tm2source)
    sink = 'mbtiles://' + os.path.abspath(mbtiles_file)

    cmd = [
        tilelive_binary,
        '--scheme', 'pyramid',
        '--bounds', bbox,
        '--minzoom', str(min_zoom),
        '--maxzoom', str(max_zoom),
        source, sink
    ]

    return cmd


def connect_job_queue(queue_name):
    conn = boto.sqs.connect_to_region(os.getenv('AWS_REGION', 'eu-central-1'))
    queue = conn.get_queue(queue_name)
    if queue is None:
        raise ValueError('Could not connect to queue {}'.format(queue_name))
    return queue


def connect_s3(bucket_name):
    #boto.set_stream_logger('paws')
    port = int(os.getenv('AWS_S3_PORT', 8080))
    print(port)
    is_secure = port == 443
    conn = S3Connection(
        os.getenv('AWS_ACCESS_KEY_ID', 'dummy'),
        os.getenv('AWS_SECRET_ACCESS_KEY', 'dummy'),
        is_secure=is_secure,
        port=port,
        host=os.getenv('AWS_S3_HOST', 'mock-s3'),
        calling_format=OrdinaryCallingFormat()
    )

    conn.create_bucket(bucket_name)
    return conn.get_bucket(bucket_name)


def upload_mbtiles(bucket, mbtiles_file):
    keyname = os.path.basename(mbtiles_file)
    obj = bucket.new_key(keyname)
    obj.set_contents_from_filename(mbtiles_file)


def export_remote(tm2source, rabbitmq_url, queue_name, render_scheme, bucket_name):
    bucket = connect_s3(bucket_name)

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
        subprocess.check_output(
            tilelive_command,
            stderr=subprocess.STDOUT,
        )
        end = time.time()

        export_logger.info('Elapsed time: {}'.format(int(end - start)),
                           extra=logging_info)
        upload_mbtiles(bucket, mbtiles_file)
        os.remove(mbtiles_file)
        export_logger.info('Upload mbtiles {}'.format(mbtiles_file),
                           extra=logging_info)

        queue.delete_message(message)

    connection = pika.BlockingConnection(pika.URLParameters(rabbitmq_url))
    channel = connection.channel()
    configure_rabbitmq(channel)

    def callback(ch, method, properties, body):
        print('Yaaay')
        body = json.loads(body.decode('utf-8'))
        print(body)

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
    properties = pika.BasicProperties(delivery_mode=2)
    channel.basic_publish(exchange='', routing_key=queue,
                          body=body, properties=properties)


def reject(channel, method):
    channel.basic_reject(delivery_tag=method.delivery_tag, requeue=False)


def main(args):
    formatter = logging.Formatter('%(ip)s %(task_id)s %(message)s')
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(formatter)

    mapnik_logger.addHandler(handler)
    export_logger.addHandler(handler)

    export_remote(
        args['--tm2source'],
        args['<rabbitmq_url>'],
        args['--job-queue'],
        args['--render_scheme'],
        args['--bucket'],
    )


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')
    main(args)

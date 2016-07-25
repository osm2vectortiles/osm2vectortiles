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
import sys
import os
import os.path
import functools
import json
import pika
from humanize import naturaltime, naturalsize
from boto.s3.connection import S3Connection, OrdinaryCallingFormat
from mbtoolbox.optimize import find_optimizable_tiles, all_descendant_tiles
from mbtoolbox.mbtiles import MBTiles
from docopt import docopt

if os.name == 'posix' and sys.version_info[0] < 3:
    import subprocess32 as subprocess
else:
    import subprocess


def s3_url(host, port, bucket_name, file_name):
    protocol = 'https' if port == 443 else 'http'
    return '{}://{}:{}/{}/{}'.format(
        protocol, host, port,
        bucket_name, file_name
    )


def connect_s3(host, port, bucket_name):
    is_secure = port == 443
    conn = S3Connection(
        os.environ['AWS_ACCESS_KEY_ID'],
        os.environ['AWS_SECRET_ACCESS_KEY'],
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
        '--timeout={}'.format(int(os.getenv('TILE_TIMEOUT', 10 * 60))),
        source, sink
    ]


def optimize_mbtiles(mbtiles_file, mask_level=8):
    mbtiles = MBTiles(mbtiles_file, 'tms')

    for tile in find_optimizable_tiles(mbtiles, mask_level, 'tms'):
        tiles = all_descendant_tiles(x=tile.x, y=tile.y,
                                     zoom=tile.z, max_zoom=14)
        mbtiles.remove_tiles(tiles)


def render_pyramid(msg, source, sink):
    pyramid = msg['pyramid']
    tileinfo = pyramid['tile']

    print('Render pyramid {}/{} from z{} down to z{}'.format(
        tileinfo['x'],
        tileinfo['y'],
        tileinfo['min_zoom'],
        tileinfo['max_zoom'],
    ))
    return render_pyramid_command(
        source, sink,
        bounds=create_tilelive_bbox(pyramid['bounds']),
        min_zoom=tileinfo['min_zoom'],
        max_zoom=tileinfo['max_zoom']
    )


def render_list(msg, source, sink):
    list_file = '/tmp/tiles.txt'
    with open(list_file, 'w') as fh:
        write_list_file(fh, msg['tiles'])

    print('Render {} tiles from list job'.format(
        len(msg['tiles']),
    ))
    return render_tile_list_command(
        source, sink,
        list_file=list_file,
    )


def timing(f, *args, **kwargs):
    start = time.time()
    ret = f(*args, **kwargs)
    end = time.time()
    return ret, end - start


def handle_message(tm2source, bucket, s3_url, body):
    msg = json.loads(body.decode('utf-8'))
    task_id = msg['id']
    mbtiles_file = task_id + '.mbtiles'

    source = 'tmsource://' + os.path.abspath(tm2source)
    sink = 'mbtiles://' + os.path.abspath(mbtiles_file)

    tilelive_cmd = []
    if msg['type'] == 'pyramid':
        tilelive_cmd = render_pyramid(msg, source, sink)
    elif msg['type'] == 'list':
        tilelive_cmd = render_list(msg, source, sink)
    else:
        raise ValueError("Message must be either of type pyramid or list")

    render_timeout = int(os.getenv('RENDER_TIMEOUT', 5 * 60))
    _, render_time = timing(subprocess.check_call, tilelive_cmd,
                            timeout=render_timeout)
    print('Render MBTiles: {}'.format(naturaltime(render_time)))

    _, optimize_time = timing(optimize_mbtiles, mbtiles_file)
    print('Optimize MBTiles: {}'.format(naturaltime(optimize_time)))

    _, upload_time = timing(upload_mbtiles, bucket, mbtiles_file)
    print('Upload MBTiles : {}'.format(naturaltime(upload_time)))

    download_link = s3_url(mbtiles_file)
    print('Uploaded {} to {}'.format(
        naturalsize(os.path.getsize(mbtiles_file)),
        download_link
    ))

    os.remove(mbtiles_file)

    return create_result_message(task_id, download_link, msg)


def export_remote(tm2source, rabbitmq_url, queue_name, result_queue_name,
                  failed_queue_name, render_scheme, bucket_name):

    if 'AWS_S3_HOST' not in os.environ:
        sys.stderr.write('You need to specify the AWS_S3_HOST')
        sys.exit(1)

    host = os.environ['AWS_S3_HOST']
    port = int(os.getenv('AWS_S3_PORT', 443))

    print('Connect with S3 bucket {} at {}:{}'.format(
        bucket_name, host, port
    ))
    bucket = connect_s3(host, port, bucket_name)

    connection = pika.BlockingConnection(pika.URLParameters(rabbitmq_url))
    channel = connection.channel()
    channel.basic_qos(prefetch_count=1)
    configure_rabbitmq(channel)
    print('Connect with RabbitMQ server {}'.format(rabbitmq_url))

    while True:
        method_frame, header_frame, body = channel.basic_get(queue_name)

        # Consumer should stop if there are no more message to receive
        if not body:
            channel.stop_consuming()
            print('No message received - stop consuming')
            break
          
        channel.basic_ack(delivery_tag=method_frame.delivery_tag)
        try:
            result_msg = handle_message(
                tm2source, bucket,
                functools.partial(s3_url, host, port, bucket_name),
                body
            )

            durable_publish(channel, result_queue_name,
                            body=json.dumps(result_msg))

        except:
            durable_publish(channel, failed_queue_name, body=body)
            channel.stop_consuming()
            time.sleep(5)  # Give RabbitMQ some time
            raise

    connection.close()


def configure_rabbitmq(channel):
    """Setup all queues and topics for RabbitMQ"""

    def queue_declare(queue):
        return channel.queue_declare(queue=queue, durable=True)

    queue_declare('jobs')
    queue_declare('failed-jobs')
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
        'failed-jobs',
        args['--render_scheme'],
        args['--bucket'],
    )


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')
    main(args)

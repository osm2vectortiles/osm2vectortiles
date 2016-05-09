#!/usr/bin/env python
"""Download and merge MBTiles back together.

Usage:
  merge-jobs.py <rabbitmq_url>  --merge-target=<mbtiles-file> [--result-queue=<result-queue>]
  merge-jobs.py (-h | --help)
  merge-jobs.py --version

Options:
  -h --help                      Show this screen.
  --version                      Show version.
  --merge-target=<mbtiles-file>  MBTiles file to merge job results into.
  --result-queue=<result-queue>  Result queue name [default: results]
"""
import os
import os.path
import json
import sqlite3
import pika
import humanize
import functools
from urllib.request import urlretrieve
from docopt import docopt


def merge_mbtiles(source, target):
    """Patch source database into target database"""
    with sqlite3.connect(target) as conn:
        cursor = conn.cursor()
        cursor.executescript("""
            PRAGMA journal_mode=PERSIST;
            PRAGMA page_size=80000;
            PRAGMA synchronous=OFF;
            ATTACH DATABASE '{0}' AS source;
            REPLACE INTO map SELECT * FROM source.map;
            REPLACE INTO images SELECT * FROM source.images;
        """.format(source))
        conn.commit()
        cursor.close()


def compare_file_after_action(filename, action):
    """Returns file size difference of a file after an action is executed"""
    old_target_size = os.path.getsize(filename)
    action()
    new_target_size = os.path.getsize(filename)
    return new_target_size - old_target_size


def download_mbtiles(download_url):
    """Download MBTiles specified in message and return local filepath"""
    merge_source = os.path.basename(download_url)
    urlretrieve(download_url, merge_source)

    if not os.path.isfile(merge_source):
        raise ValueError('File {} does not exist'.format(merge_source))

    merge_source_size = os.path.getsize(merge_source)
    print('Download {} ({})'.format(
        download_url,
        humanize.naturalsize(merge_source_size))
    )
    return merge_source


def merge_results(rabbitmq_url, merge_target, result_queue_name):
    if not os.path.isfile(merge_target):
        raise ValueError('File {} does not exist'.format(merge_target))

    connection = pika.BlockingConnection(pika.URLParameters(rabbitmq_url))
    channel = connection.channel()
    channel.basic_qos(prefetch_count=3)
    channel.confirm_delivery()

    def callback(ch, method, properties, body):
        msg = json.loads(body.decode('utf-8'))
        merge_source = download_mbtiles(msg['url'])
        action = functools.partial(merge_mbtiles, merge_source, merge_target)
        diff_size = compare_file_after_action(merge_target, action)

        print("Merge {} from {} into {}".format(
            humanize.naturalsize(diff_size),
            merge_source,
            merge_target
        ))

        os.remove(merge_source)
        ch.basic_ack(delivery_tag=method.delivery_tag)

    channel.basic_consume(callback, queue=result_queue_name)
    try:
        channel.start_consuming()
    except KeyboardInterrupt:
        channel.stop_consuming()

    connection.close()


def main(args):
    merge_results(
        args['<rabbitmq_url>'],
        args['--merge-target'],
        args['--result-queue']
    )


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')
    main(args)

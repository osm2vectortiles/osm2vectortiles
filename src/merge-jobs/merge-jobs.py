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
from urllib.request import urlretrieve
from docopt import docopt


def merge_mbtiles(source, target):
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


def merge_results(rabbitmq_url, merge_target, result_queue_name):
    if not os.path.isfile(merge_target):
        raise ValueError('File {} does not exist'.format(merge_target))

    connection = pika.BlockingConnection(pika.URLParameters(rabbitmq_url))
    channel = connection.channel()

    def callback(ch, method, properties, body):
        msg = json.loads(body.decode('utf-8'))
        download_url = msg['url']
        merge_source = os.path.basename(download_url)

        urlretrieve(download_url, merge_source)

        merge_source_size = os.path.getsize(merge_source)
        if not os.path.isfile(merge_source):
            raise ValueError('File {} does not exist'.format(merge_source))

        print('Download {} ({})'.format(
            download_url,
            humanize.naturalsize(merge_source_size))
        )

        old_target_size = os.path.getsize(merge_target)
        merge_mbtiles(merge_source, merge_target)
        new_target_size = os.path.getsize(merge_target)
        diff_size = new_target_size - old_target_size

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

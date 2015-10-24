#!/usr/bin/env python
"""Export vector tiles from OpenStreetMap

Usage:
  export.py local <mbtiles_file> [--bbox=<bbox>] [--min_zoom=<min_zoom>] [--max_zoom=<max_zoom>] [--render_scheme=<scheme>] [--src_project_dir=<src>] [--dst_project_dir=<dst>] [--export_dir=<export_dir>] [--db_host=<db_host>] [--db_port=<db_port>] [--db_user=<db_user>] [--db_name=<db_name>] [--db_pass=<db_pass>] [--db_schema=<db_schema>]
  export.py remote <sqs_queue> [--render_scheme=<scheme>] [--src_project_dir=<src>] [--dst_project_dir=<dst>] [--export_dir=<export_dir>] [--db_host=<db_host>] [--db_port=<db_port>] [--db_user=<db_user>] [--db_name=<db_name>] [--db_pass=<db_pass>] [--db_schema=<db_schema>]
  export.py (-h | --help)
  export.py --version

Options:
  -h --help                 Show this screen.
  --version                 Show version.
  --bbox=<bbox>             WGS84 bounding box [default: -180, -85.0511, 180, 85.0511].
  --min_zoom=<min_zoom>     Minimum zoom [default: 8].
  --max_zoom=<max_zoom>     Maximum zoom  [default: 12].
  --render_scheme=<scheme>  Either pyramid or scanline [default: pyramid]
  --src_project_dir=<src>   Directory of tm2source [default: .]
  --dst_project_dir=<dst>   Temporary location of modified tm2source [default: /tmp/project]
  --export_dir=<export_dir> Location for exported MBTiles [default: /tmp/export]
  --db_host=<db_host>       Database host [default: localhost]
  --db_port=<db_port>       Database port [default: 5432]
  --db_user=<db_user>       Database port [default: osm]
  --db_name=<db_name>       Database port [default: osm]
  --db_pass=<db_pass>       Database port [default: osm]
  --db_schema=<db_schema>   Database schema [default: public]
"""
import shutil
import yaml
from docopt import docopt


def copy_source_project(source_project_dir, dest_project_dir):
    """
    Project config will be copied to new folder because we
    modify the source configuration
    """
    shutil.copytree(source_project_dir, dest_project_dir)


def replace_db_connection(config_file, host, port, user, dbname, password):
    """
    Replace database connection in YAML config file
    with specified database arguments
    """
    with open(config_file, 'r') as stream:
        print(yaml.load(stream))


if __name__ == '__main__':
    arguments = docopt(__doc__, version='0.1')
    print(arguments)

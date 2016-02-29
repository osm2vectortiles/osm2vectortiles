#!/usr/bin/env python
"""Generate taginfo project from imposm mapping schema.
Usage:
  generate_taginfo.py <mapping_file>
  generate_taginfo.py (-h | --help)
  generate_taginfo.py --version
Options:
  -h --help         Show this screen.
  --version         Show version.
"""
from collections import namedtuple, defaultdict
from docopt import docopt
import sys
import yaml
import json


Table = namedtuple('Table', ['name', 'fields', 'mapping', 'type'])


def merge_grouped_mappings(mappings):
    """Merge multiple mappings into a single mapping for drawing"""
    for mapping_group, mapping_value in mappings.items():
        yield mapping_group, mapping_value['mapping']


def find_tables(config):
    for table_name, table_value in config['tables'].items():
        fields = table_value.get('fields')

        if table_value.get('mappings'):
            mapping = list(merge_grouped_mappings(table_value['mappings']))
        else:
            mapping = table_value.get('mapping').items()

        if mapping and fields:
            yield Table(table_name, fields, mapping, table_value['type'])


def find_tags(mapping_config):
    tags = defaultdict(list)
    for table in find_tables(mapping_config):
        for osm_key, osm_values in table.mapping:
            tags[osm_key] += osm_values

    return tags

def generate_tags_json(mapping_config):
    for key, values in find_tags(mapping_config).items():
        for value in values:
            yield {
                "key": key,
                "value": value
            }

def generate_taginfo(mapping_config):
    return json.dumps({
        "data_format": 1,
        "project": {                
           "name": "OSM2VectorTiles",
           "description": "Free Vector Tiles from OpenStreetMap",
           "project_url": "http://osm2vectortiles.org/",
           "doc_url": "http://osm2vectortiles.org/docs/",
           "icon_url": "http://osm2vectortiles.org/img/osm2vectortiles-logo-small-white.png",
           "contact_name": "Lukas Martinelli",
           "contact_email": "me@lukasmartinelli.ch"
        },
        "tags": list(generate_tags_json(mapping_config))
    }, indent=4, sort_keys=True)



if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')
    mapping_file = args.get('<mapping_file>')

    mapping_config = yaml.load(open(mapping_file, 'r'))
    taginfo = generate_taginfo(mapping_config)
    print(taginfo)

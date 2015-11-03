#!/usr/bin/env python
"""Generate diagrams from imposm mapping schema. Only supports YAML.
Usage:
  generate_diagram.py mapping <mapping_file>
  generate_diagram.py layers <tm2source_file>
  generate_diagram.py (-h | --help)
  generate_diagram.py --version
Options:
  -h --help                 Show this screen.
  --version                 Show version.
"""
import re
from collections import namedtuple

from docopt import docopt
import yaml
from graphviz import Digraph


Layer = namedtuple('Layer', ['name', 'referenced_tables', 'fields'])
Table = namedtuple('Table', ['name', 'fields', 'mapping', 'type'])


class TableMapping(object):
    def __init__(self, table_name, mappings):
        self.table_name = table_name
        self.mappings = mappings

    def visualize_mapping(self):
        subgraph = Digraph(self.table_name)
        subgraph.node(self.table_name, shape='box')

        for osm_key, osm_values in self.mappings:
            node_name = osm_key.replace(':', '_')
            subgraph.node(node_name, label=osm_key, shape='box')
            subgraph.edge(node_name, self.table_name)

        return subgraph


def find_mappings(config):
    for table_name, table_value in config['tables'].items():
        mapping = table_value.get('mapping')
        if mapping:
            yield TableMapping(table_name, mapping.items())


def find_referenced_tables(sql_cmd, table_prefix="osm"):
    table_regex = re.compile("FROM {}_(\w*)".format(table_prefix), re.IGNORECASE)
    matches = table_regex.findall(sql_cmd)
    return matches


def is_generalized_table(table_name):
    return re.match("_gen\d", table_name)


def find_layers(config):
    for layer in config['Layer']:
        layer_name = layer['id']
        sql_cmd = layer['Datasource']['table']

        tables = [t for t in find_referenced_tables(sql_cmd)
                if not is_generalized_table(t)]

        fields = layer['fields'].items()
        yield Layer(layer_name, tables, fields)


def generate_layer_node(graph, layer):
    field_names = [field_name for field_name, _ in layer.fields]
    node_body = '''<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">
  <TR>
    <TD PORT="name" BGCOLOR="#EEEEEE">#{0}</TD>
  </TR>
  <TR>
    <TD>{1}</TD>
  </TR>
</TABLE>>'''.format(layer.name, '<BR/>'.join(field_names))
    graph.node(layer.name, node_body, shape='plaintext')


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')

    if args.get('layers'):
        tm2source_file = args['<tm2source_file>']
        graph = Digraph('Layers', format='png', graph_attr={
            'rankdir': 'LR'
        })
        with open(tm2source_file, 'r') as f:
            config = yaml.load(f)
            for layer in find_layers(config):
                generate_layer_node(graph, layer)

            graph.render(filename='layer_diagram', view=True)

    if args.get('mapping'):
        mapping_file = args['<mapping_file>']
        with open(mapping_file, 'r') as f:
            config = yaml.load(f)
            graph = Digraph('Imposm Mapping', format='png', graph_attr={
                'rankdir': 'LR'
            })
            for table_mapping in find_mappings(config):
                graph.subgraph(table_mapping.visualize_mapping())

            filename = graph.render(filename='mapping_graph', view=True)


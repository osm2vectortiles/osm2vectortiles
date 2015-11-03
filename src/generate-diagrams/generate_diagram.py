#!/usr/bin/env python
"""Generate diagrams from imposm mapping schema. Only supports YAML.
Usage:
  generate_diagram.py <mapping_file>
  generate_diagram.py (-h | --help)
  generate_diagram.py --version
Options:
  -h --help                 Show this screen.
  --version                 Show version.
"""
from docopt import docopt
import yaml
from graphviz import Digraph


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


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')
    mapping_file = args['<mapping_file>']

    with open(mapping_file, 'r') as f:
        config = yaml.load(f)
        graph = Digraph('Imposm Mapping', format='png', graph_attr={
            'rankdir': 'LR'
        })
        for table_mapping in find_mappings(config):
            graph.subgraph(table_mapping.visualize_mapping())

        filename = graph.render(filename='mapping_graph', view=True)

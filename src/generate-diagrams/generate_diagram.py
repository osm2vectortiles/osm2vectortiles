#!/usr/bin/env python
"""Generate diagrams from imposm mapping schema and tm2source project.
Usage:
  generate_diagram.py mapping-keys <mapping_file>
  generate_diagram.py mapping-layers <tm2source_file> <mapping_file>
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

    def _values_label(self, osm_values):
        return '[{} values]'.format(len(osm_values))

    def visualize_mapping(self):
        subgraph = Digraph(self.table_name, node_attr={
            'width:': '20',
            'fixed_size': 'shape'
        })
        subgraph.node(self.table_name, shape='box')

        for osm_key, osm_values in self.mappings:
            node_name = osm_key.replace(':', '_')
            subgraph.node(node_name, label=osm_key, shape='box')

            subgraph.edge(node_name, self.table_name,
                          label=self._values_label(osm_values))

        return subgraph


def find_mappings(config):
    for table_name, table_value in config['tables'].items():
        mapping = table_value.get('mapping')
        if mapping:
            yield TableMapping(table_name, mapping.items())


def find_referenced_tables(sql_cmd, table_prefix="osm"):
    """Find all tables used in SQL FROM statements"""

    regexpr = "FROM {}_(\w*)".format(table_prefix)
    table_regex = re.compile(regexpr, re.IGNORECASE)
    for match in table_regex.findall(sql_cmd):
        yield replace_generalization_postfix(match)


def replace_generalization_postfix(table_name):
    return table_name.replace('_gen0', '').replace('_gen1', '')


def merge_grouped_mappings(mappings):
    """Merge multiple mappings into a single mapping for drawing"""
    for mapping_group, mapping_value in mappings.items():
        yield from mapping_value


def find_tables(config):
    for table_name, table_value in config['tables'].items():
        fields = table_value.get('fields')

        if table_value.get('mappings'):
            mapping = merge_grouped_mappings(table_value)
        else:
            mapping = table_value.get('mapping').items()

        if mapping and fields:
            yield Table(table_name, fields, mapping, table_value['type'])


def find_layers(config):
    for layer in config['Layer']:
        layer_name = layer['id']
        sql_cmd = layer['Datasource']['table']

        tables = set([t for t in find_referenced_tables(sql_cmd)])

        fields = layer['fields'].items()
        yield Layer(layer_name, tables, fields)


def generate_table_node(graph, table):
    field_names = [field['name'] for field in table.fields]
    node_body = '''<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">
  <TR>
    <TD BGCOLOR="#EEEEEE">{0}</TD>
  </TR>
  <TR>
    <TD>{1}</TD>
  </TR>
</TABLE>>'''.format(table.name, '<BR/>'.join(field_names))
    node_name = 'table_' + table.name
    graph.node(node_name, node_body, shape='none')
    return node_name


def generate_layer_node(graph, layer):
    field_names = [field_name for field_name, _ in layer.fields]
    node_body = '''<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">
  <TR>
    <TD BGCOLOR="#EEEEEE">{0}</TD>
  </TR>
  <TR>
    <TD>{1}</TD>
  </TR>
</TABLE>>'''.format('#' + layer.name, '<BR/>'.join(field_names))
    node_name = 'layer_' + layer.name
    graph.node(node_name, node_body, shape='none')
    return node_name


def generate_table_layer_diagram(mapping_config, tm2source_config):
    graph = Digraph('Layers from Table Mappings', format='png', graph_attr={
        'rankdir': 'LR'
    })

    layers = find_layers(tm2source_config)
    tables = find_tables(mapping_config)

    table_nodes = [generate_table_node(graph, table) for table in tables]
    for layer in layers:
        layer_node = generate_layer_node(graph, layer)
        for table_name in layer.referenced_tables:
            graph.edge('table_' + table_name, layer_node)

    graph.render(filename='table_layer_diagram', view=True)

def generate_table_mapping_diagram(mapping_config):
    graph = Digraph('Imposm Mapping', format='png', graph_attr={
        'rankdir': 'LR',
        'ranksep': '3'
    })

    for table_mapping in find_mappings(mapping_config):
        graph.subgraph(table_mapping.visualize_mapping())

    graph.render(filename='mapping_graph', view=True)


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')
    mapping_file = args.get('<mapping_file>')
    tm2source_file = args.get('<tm2source_file>')

    if args.get('mapping-layers'):
        mapping_config = yaml.load(open(mapping_file, 'r'))
        tm2source_config = yaml.load(open(tm2source_file, 'r'))
        generate_table_layer_diagram(mapping_config, tm2source_config)

    if args.get('mapping-keys'):
        mapping_config = yaml.load(open(mapping_file, 'r'))
        generate_table_mapping_diagram(mapping_config)


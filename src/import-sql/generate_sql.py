#!/usr/bin/env python
"""Generate SQL functions from custom YAML definitions
Usage:
  generate_sql.py class <yaml-source>
  generate_sql.py changed_tiles <yaml-source>
  generate_sql.py tables <yaml-source>
  generate_sql.py (-h | --help)
Options:
  -h --help                 Show this screen.
  --version                 Show version.
"""
from collections import namedtuple
from docopt import docopt
import yaml


SQL_INDENT = 8 * " "
Class = namedtuple('Class', ['name', 'values'])


def generate_sql_class(source, func_suffix='class'):
    def gen_when_stmt(class_name, mapping_values):
        in_statements = ["'{}'".format(value) for value in mapping_values]
        return " " * 12 + "WHEN type IN ({0}) THEN '{1}'".format(
            ','.join(in_statements),
            class_name
        )

    system_name = source['system']['name']
    classes = find_classes(source)

    when_statements = [gen_when_stmt(cl, val) for cl, val in classes]

    return """CREATE OR REPLACE FUNCTION {0}_{1}(type VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
    RETURN CASE
{2}
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
    """.format(system_name, func_suffix, "\n".join(when_statements))


def find_classes(config):
    for cl_name, mapped_values in config['system']['classes'].items():
        yield Class(cl_name, mapped_values)


Table = namedtuple('Table', ['name', 'buffer', 'min_zoom', 'max_zoom'])


def generate_changed_tiles(
        tables,
        func_name='changed_tiles',
        func_changed_tiles_query='changed_tiles_table'
    ):


    def gen_select_stmt(table):
        return "SELECT * FROM {0}('{1}', ts, {2}, {3}, {4})".format(
            func_changed_tiles_query,
            table.name,
            table.buffer,
            table.min_zoom,
            table.max_zoom,
        )

    stmts = [2 * SQL_INDENT + gen_select_stmt(t) for t in tables]
    separator = '\n' + 2 * SQL_INDENT + 'UNION\n'
    return """CREATE OR REPLACE FUNCTION {0}(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
    RETURN QUERY (
{1}
    );
END;
$$ language plpgsql;
    """.format(func_name, separator.join(stmts))


def generate_static_table_view(tables, view_name='osm_tables'):

    def gen_select_stmt(table):
        return ("SELECT '{0}' AS table_name,"
        '{1} AS buffer_size,'
        '{2} AS min_zoom,'
        '{3} AS max_zoom').format(table.name, table.buffer,
                                  table.min_zoom, table.max_zoom)

    stmts = [SQL_INDENT + gen_select_stmt(t) for t in tables]
    sep = '\n' + SQL_INDENT + 'UNION\n'
    return 'CREATE OR REPLACE VIEW {0} AS (\n{1}\n);'.format(view_name,
                                                             sep.join(stmts))


def find_delete_tables(config, delete_suffix='delete'):
    for src_table in find_tables(config):
        yield Table(src_table.name + '_' + delete_suffix,
                    src_table.buffer,
                    src_table.min_zoom, src_table.max_zoom)


def find_tables_with_deletes(config):
    for src_table in find_tables(config):
        yield src_table

    for delete_table in find_delete_tables(config):
        yield delete_table


def find_tables(config, schema_prefix='osm'):
    for table_name, config_values in config['tables'].items():
        yield Table(schema_prefix + '_' + table_name,config_values['buffer'],
                    config_values['min_zoom'], config_values['max_zoom'])


if __name__ == '__main__':
    args = docopt(__doc__)

    with open(args['<yaml-source>'], 'r') as f:
        source = yaml.load(f)
        if args['class']:
            print(generate_sql_class(source))
        if args['changed_tiles']:
            print(generate_changed_tiles(find_tables_with_deletes(source)))
        if args['tables']:
            print(generate_static_table_view(find_tables(source)))

#!/usr/bin/env python
"""Generate SQL functions from custom YAML definitions
Usage:
  generate_sql.py class <yaml-source>
  generate_sql.py tracking <yaml-source>
  generate_sql.py update_timestamp <yaml-source>
  generate_sql.py (-h | --help)
Options:
  -h --help                 Show this screen.
  --version                 Show version.
"""
from collections import namedtuple
from docopt import docopt
import yaml


Class = namedtuple('Class', ['name', 'values'])


def generate_sql_class(source, func_suffix='class'):
    def generate_when_statement(class_name, mapping_values):
        in_statements = ["'{}'".format(value) for value in mapping_values]
        return " " * 12 + "WHEN type IN ({0}) THEN '{1}'".format(
            ','.join(in_statements),
            class_name
        )

    system_name = source['system']['name']
    classes = find_classes(source)

    when_statements = [generate_when_statement(cl, val) for cl, val in classes]

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


def generate_update_timestamp(
        tables,
        func_name='update_timestamp',
        timestamp_field='timestamp'
    ):

    def gen_update_stmt(table):
	return 'UPDATE {0} SET {1}=ts WHERE {1} IS NULL;'.format(
            table.name,
            timestamp_field
        );

    indent = 4 * " "
    stmts = [indent + gen_update_stmt(t) for t in tables]
    return """CREATE OR REPLACE FUNCTION {0}(ts timestamp) returns VOID
AS $$
BEGIN
{1}
END;
$$ language plpgsql;
    """.format(func_name, "\n".join(stmts))


def generate_tracking_triggers(
        tables,
        func_name='create_tracking_triggers',
        recreate_func_name='recreate_osm_delete_tracking'
    ):

    def gen_perform_stmt(table):
        return "PERFORM {0}('{1}');".format(recreate_func_name, table.name)

    indent = 4 * " "
    stmts = [indent + gen_perform_stmt(t) for t in tables]
    return """CREATE OR REPLACE FUNCTION {0}() returns VOID
AS $$
BEGIN
{1}
END;
$$ language plpgsql;
    """.format(func_name, "\n".join(stmts))


def find_tables_with_deletes(config, delete_suffix='delete'):
    for src_table in find_tables(config):
        yield src_table
        yield Table(src_table.name + '_' + delete_suffix,
                    src_table.buffer,
                    src_table.min_zoom,
                    src_table.max_zoom)


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

        tables = find_tables(source)
        if args['tracking']:
            print(generate_tracking_triggers(find_tables(source)))
        if args['update_timestamp']:
            print(generate_update_timestamp(find_tables_with_deletes(source)))

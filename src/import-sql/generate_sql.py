#!/usr/bin/env python
"""Generate SQL functions from custom YAML definitions
Usage:
  generate_sql.py class <yaml-source>
  generate_sql.py tracking_triggers <yaml-source>
  generate_sql.py create_delete_tables <yaml-source>
  generate_sql.py create_delete_indizes <yaml-source>
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


def generate_create_delete_indizes(
        tables,
        func_name='create_osm_delete_indizes',
        create_index_func='create_osm_delete_index'
    ):

    def gen_perform_stmt(table):
        return "PERFORM {0}('{1}');".format(create_index_func, table.name)

    indent = 4 * " "
    stmts = [indent + gen_perform_stmt(t) for t in tables]
    return """CREATE OR REPLACE FUNCTION {0}() returns VOID
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


def generate_create_delete_tables(
        tables,
        func_name='create_delete_tables',
        create_table_func='create_delete_table'
    ):

    def gen_perform_stmt(table):
        return "PERFORM {0}('{1}');".format(create_table_func, table.name)

    indent = 4 * " "
    stmts = [indent + gen_perform_stmt(t) for t in tables]
    return """CREATE OR REPLACE FUNCTION {0}() returns VOID
AS $$
BEGIN
{1}
END;
$$ language plpgsql;
    """.format(func_name, "\n".join(stmts))


def generate_changed_tiles(
        tables,
        func_name='changed_tiles',
        func_changed_tiles_query='changed_tiles_table'
    ):

    indent = 8 * " "

    def gen_select_stmt(table):
        return "SELECT * FROM {0}('{1}', ts, {2}, {3}, {4})".format(
            func_changed_tiles_query,
            table.name,
            table.buffer,
            table.min_zoom,
            table.max_zoom,
        )

    stmts = [indent + gen_select_stmt(t) for t in tables]
    separator = '\n' + indent + 'UNION\n'
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

    indent = 4 * " "
    stmts = [indent + gen_select_stmt(t) for t in tables]
    sep = '\n' + indent + 'UNION\n'
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

        tables = find_tables(source)
        if args['tracking_triggers']:
            print(generate_tracking_triggers(find_tables(source)))
        if args['create_delete_tables']:
            print(generate_create_delete_tables(find_delete_tables(source)))
        if args['create_delete_indizes']:
            print(generate_create_delete_indizes(find_delete_tables(source)))
        if args['changed_tiles']:
            print(generate_changed_tiles(find_tables_with_deletes(source)))
        if args['tables']:
            print(generate_static_table_view(find_tables(source)))

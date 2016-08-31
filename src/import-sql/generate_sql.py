#!/usr/bin/env python
"""Generate SQL functions from custom YAML definitions
Usage:
  generate_sql.py class <yaml-source>
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


if __name__ == '__main__':
    args = docopt(__doc__)

    with open(args['<yaml-source>'], 'r') as f:
        source = yaml.load(f)
        if args['class']:
            print(generate_sql_class(source))

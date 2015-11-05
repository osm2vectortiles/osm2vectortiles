#!/usr/bin/env python
"""Generate PostgreSQL classify functions from custom YAML mapping
Usage:
  generate_sql.py <config_file>
  generate_sql.py (-h | --help)
Options:
  -h --help                 Show this screen.
  --version                 Show version.
"""
from collections import namedtuple
from docopt import docopt
import yaml


Classification = namedtuple('Classification', ['name', 'mappings'])


def generate_sql(classification):
    when_statements = [_generate_when_statement(cl, val) for cl, val in
                       classification.mappings]

    return """CREATE OR REPLACE FUNCTION classify_{0}(type VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
    RETURN CASE
{1}
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
    """.format(classification.name, "\n".join(when_statements))


def _generate_when_statement(class_name, mapping_values):
    in_statements = ["'{}'".format(value) for value in mapping_values]
    return " " * 12 + "WHEN type IN ({0}) THEN '{1}'".format(
        ','.join(in_statements),
        class_name
    )


def find_classifications(config):
    for cl_name, cl_value in config['classifications'].items():
        mappings = cl_value.items()
        yield Classification(cl_name, mappings)


if __name__ == '__main__':
    args = docopt(__doc__)
    config_file = args['<config_file>']

    with open(config_file, 'r') as f:
        config = yaml.load(f)
        for cl in find_classifications(config):
            print(generate_sql(cl))

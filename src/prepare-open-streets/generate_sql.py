#!/usr/bin/env python
"""Generate PostgreSQL classify functions from custom YAML mapping
Usage:
  generate_sql.py <config_file>
  generate_sql.py (-h | --help)
Options:
  -h --help                 Show this screen.
  --version                 Show version.
"""
from docopt import docopt
import yaml


class Classification(object):
    """Classification of a type (YAML key) to a class (YAML values)"""
    def __init__(self, classification_name, mappings):
        self.classification_name = classification_name
        self.mappings = mappings

    def generate_sql(self):
        generate_when = Classification._generate_when_statement
        when_statements = [generate_when(cl, val) for cl, val in self.mappings]

        return """CREATE OR REPLACE FUNCTION classify_{0}(type VARCHAR)
RETURNS VARCHAR AS $$
    BEGIN
        RETURN CASE
{1}
        END;
    END;
$$ LANGUAGE plpgsql IMMUTABLE;
        """.format(self.classification_name, "\n".join(when_statements))

    @staticmethod
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
            print(cl.generate_sql())

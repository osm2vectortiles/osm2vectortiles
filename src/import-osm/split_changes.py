#!/usr/bin/env python
"""Split OsmChange file into deletes, modifies and creates.

Usage:
  split_changes.py <change_file> --type=<change_type>
  split_changes.py (-h | --help)
  split_changes.py --version

Options:
  -h --help              Show this screen
  --version              Show version
  --type=<change_type>   Either delete, modify, create [default: create]
"""
import os
import sys
import gzip
from lxml import etree
from docopt import docopt



def main(args):
    change_file = args['<change_file>']
    change_type = args['--type']
    possible_change_types = ['delete', 'modify', 'create']

    with gzip.open(change_file, 'rb') as file_handle:
        context = etree.iterparse(file_handle, events=('end',), tag=)


        context = etree.iterparse(file_handle, events=('end',), tag=change_type)
        for event, elem in context:
            etree.ElementTree(elem).write(sys.stdout, encoding='UTF-8')
            elem.clear()


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')
    main(args)

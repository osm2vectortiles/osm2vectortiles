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
import xml.etree.ElementTree as ET
from docopt import docopt



def main(args):
    change_file = args['<change_file>']
    filter_change_type = args['--type']
    possible_change_types = ['delete', 'modify', 'create']

    with gzip.open(change_file, 'rb') as file_handle:
        tree = ET.parse(file_handle)
        root = tree.getroot()
        for change_type in possible_change_types:
            if change_type != filter_change_type:
                for tag in root.findall(change_type):
                    root.remove(tag)

        tree.write(sys.stdout)


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')
    main(args)

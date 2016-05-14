#!/usr/bin/env python
"""Calculate QuadKey for TSV file and append it as column

Usage:
  calculate_quad_key.py <list_file>
  calculate_quad_key.py (-h | --help)
  calculate_quad_key.py --version

Options:
  -h --help                    Show this screen.
  --version                    Show version.
"""
import system
import csv
from docopt import docopt


def quad_tree(tx, ty, zoom):
    """
    Converts XYZ tile coordinates to Microsoft QuadTree
    http://www.maptiler.org/google-maps-coordinates-tile-bounds-projection/
    """
    quad_key = ''
    for i in range(zoom, 0, -1):
        digit = 0
        mask = 1 << (i-1)
        if (tx & mask) != 0:
            digit += 1
        if (ty & mask) != 0:
            digit += 2
        quad_key += str(digit)

    return quad_key


if __name__ == '__main__':
    args = docopt(__doc__, version='0.1')

    writer = csv.writer(system.out)
    with open(args['<list_file>'], "r") as file_handle:
        for line in file_handle:
            z, x, y = line.split('/')

            writer.writerow([
                line,
                quad_tree(int(x), int(y), int(z))]
            )

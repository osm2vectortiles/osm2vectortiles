#!/usr/bin/env python
"""Export vector tiles from OpenStreetMap

Usage:
  export.py local <mbtiles_file> --tm2source=<tm2source> [--bbox=<bbox>] [--min_zoom=<min_zoom>] [--max_zoom=<max_zoom>] [--render_scheme=<scheme>]
  export.py remote <sqs_queue> --tm2source=<tm2source> [--render_scheme=<scheme>]
  export.py (-h | --help)
  export.py --version

Options:
  -h --help                 Show this screen.
  --version                 Show version.
  --bbox=<bbox>             WGS84 bounding box [default: -180, -85.0511, 180, 85.0511].
  --min_zoom=<min_zoom>     Minimum zoom [default: 8].
  --max_zoom=<max_zoom>     Maximum zoom  [default: 12].
  --render_scheme=<scheme>  Either pyramid or scanline [default: pyramid]
  --tm2source=<tm2source>   Directory of tm2source
"""
import subprocess
import os.path

from docopt import docopt


def create_tilelive_command(tm2source, mbtiles_file, bbox,
                            min_zoom=8, max_zoom=12, scheme='pyramid'):
    tilelive_binary = os.getenv('TILELIVE_BIN', 'tl')
    source = 'tmsource://' + os.path.abspath(tm2source)
    sink = 'mbtiles://' + os.path.abspath(mbtiles_file)

    cmd = [
        tilelive_binary, 'copy',
        '-s', 'pyramid',
        '-b', bbox,
        '--min-zoom', str(min_zoom),
        '--max-zoom', str(max_zoom),
        source, sink
    ]

    return cmd


def export_local(tilelive_command):
    print(tilelive_command)
    proc = subprocess.Popen(
        tilelive_command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        bufsize=0,
        universal_newlines=True
    )
    for line in iter(proc.stdout.readline, ''):
        print line.rstrip()

    proc.wait()
    if proc.returncode != 0:
        raise subprocess.CalledProcessError(returncode=proc.returncode,
                                            cmd=tilelive_command)


if __name__ == '__main__':
    arguments = docopt(__doc__, version='0.1')
    print(arguments)
    if arguments.get('local'):
        tilelive_command = create_tilelive_command(
            arguments['--tm2source'],
            arguments['<mbtiles_file>'],
            arguments['--bbox'],
            arguments['--min_zoom'],
            arguments['--max_zoom'],
            arguments['--render_scheme']
        )
        export_local(tilelive_command)

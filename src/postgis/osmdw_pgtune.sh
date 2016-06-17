#! /bin/bash
set -o errexit
set -o pipefail
set -o nounset

echo "Running pgtune...  minimal tunning for OSM DW"

# pgtune works by taking an existing postgresql.conf file as an input,
# making changes to it based on the amount of RAM in your server
# and suggested workload, and output a new file.
# see more : https://github.com/elitwin/pgtune
python /pgtune/pgtune --version 9.5 \
                      --connections 30 \
                      --type DW \
                      --input-config $PGDATA/postgresql.conf \
                      --output-config $PGDATA/postgresql.conf.pgtune

mv $PGDATA/postgresql.conf $PGDATA/postgresql.conf.backup
mv $PGDATA/postgresql.conf.pgtune $PGDATA/postgresql.conf


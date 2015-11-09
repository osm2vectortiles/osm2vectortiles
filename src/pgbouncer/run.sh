#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly OSM_DB="$PG_PORT_5432_TCP_ADDR"
readonly OSM_PORT="$PG_PORT_5432_TCP_PORT"
readonly OSM_USER=${OSM_USER:-osm}
readonly OSM_PASSWORD=${OSM_PASSWORD:-osm}
readonly PGB_CONF_FILE="/etc/pgbouncer/pgbconf.ini"
readonly PGB_USERLIST_FILE="/etc/pgbouncer/userlist.txt"

function fix_permissions() {
    chown -R postgres:postgres /etc/pgbouncer
    chown root:postgres /var/log/postgresql
    chmod 1775 /var/log/postgresql
    chmod 640 "$PGB_USERLIST_FILE"
}

function run_pgbouncer() {
    exec /usr/sbin/pgbouncer -u postgres "$PGB_CONF_FILE"
}

function configure_db() {
    sed -i "s/host=osm_db/host=$OSM_DB/g" "$PGB_CONF_FILE"
    sed -i "s/host=5432/host=$OSM_PORT/g" "$PGB_CONF_FILE"
}

function configure_user() {
    if [ ! -s "$PGB_USERLIST_FILE" ]; then
        echo '"'"${OSM_USER}"'" "'"${OSM_PASSWORD}"'"'  > "$PGB_USERLIST_FILE"
    fi
}

configure_db
configure_user
fix_permissions
run_pgbouncer

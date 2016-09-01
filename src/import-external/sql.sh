#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly PGCONN="dbname=$POSTGRES_ENV_POSTGRES_DB user=$POSTGRES_ENV_POSTGRES_USER host=$POSTGRES_PORT_5432_TCP_ADDR port=5432"

function exec_psql() {
    PGPASSWORD=$POSTGRES_ENV_POSTGRES_PASSWORD psql \
        -v ON_ERROR_STOP=1 \
        --host="$POSTGRES_PORT_5432_TCP_ADDR" \
        --port="5432" \
        --dbname="$POSTGRES_ENV_POSTGRES_DB" \
        --username="$POSTGRES_ENV_POSTGRES_USER"
}

function exec_sql_file() {
	local sql_file=$1
    exec_psql < "$sql_file"
}

function drop_table() {
    local table=$1
	local drop_command="DROP TABLE IF EXISTS $table;"
	echo "$drop_command" | exec_psql
}

function hide_inserts() {
    grep -v "INSERT 0 1"
}

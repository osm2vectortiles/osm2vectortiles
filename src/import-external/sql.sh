#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

readonly POSTGRES_HOST=${POSTGRES_HOST:-"postgres"}
readonly PGCONN="dbname=$POSTGRES_DB user=$POSTGRES_USER host=$POSTGRES_HOST password=$POSTGRES_PASSWORD port=5432"

function exec_psql() {
    PGPASSWORD="$POSTGRES_PASSWORD" psql \
        -v ON_ERROR_STOP=1 \
        --host="$POSTGRES_HOST" \
        --port="5432" \
        --dbname="$POSTGRES_DB" \
        --username="$POSTGRES_USER"
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

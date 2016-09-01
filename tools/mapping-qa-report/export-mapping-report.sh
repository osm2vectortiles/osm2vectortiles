#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

function exec_sql_file() {
    local file_name="$1"
    PGPASSWORD="$POSTGRES_PASSWORD" psql \
        -v ON_ERROR_STOP=1 \
        --host="$POSTGRES_HOST" \
        --port="5432" \
        --dbname="$POSTGRES_DB" \
        --username="$POSTGRES_USER" \
        -f "$file_name"
}

function export_tsv() {
    local tsv_filename="$1"
    local tsv_file="$QA_DIR/$tsv_filename"
    local sql_file="$2"

    pgclimb \
        -f "$sql_file" \
        -o "$tsv_file" \
        -dbname "$POSTGRES_DB" \
        --username "$POSTGRES_USER" \
        --host "$POSTGRES_HOST" \
        --port "5432" \
        --pass "$POSTGRES_PASSWORD" \
    tsv --header
}

function export_report() {
    exec_sql_file "functions.sql"
    export_tsv "mapping_report.tsv" "report.sql"
}

export_report

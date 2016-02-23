#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

source import.sh

function main() {
    import_diff_changes "$IMPORT_DATA_DIR"
}

main

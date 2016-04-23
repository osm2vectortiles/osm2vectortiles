#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

function import_all() {
    ./import-natural-earth.sh && \
    ./import-water.sh && \
    ./import-labels.sh
}

import_all

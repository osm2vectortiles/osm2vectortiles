#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

function import_all() {
    ./import-contour.sh
}

import_all

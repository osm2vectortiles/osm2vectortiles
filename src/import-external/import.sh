#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

source import-natural-earth.sh
source import-labels.sh
source import-water.sh

function import_all_external() {
    import_natural_earth
    import_labels
    import_water
}

import_all_external

#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

source_data_dir=${SOURCE_DATA_DIR:-/data}
dest_data_dir=${DEST_DATA_DIR:-/project}
port=${PORT:-8080}
cache_size=${CACHE_SIZE:-10}
source_cache_size=${SOURCE_CACHE_SIZE:-10}

# find all tm2 projects but only the first project will be hosted for now
for project_dir in "$source_data_dir"/*.tm2; do
    project_name="${project_dir##*/}"
    project_config_file="${project_dir%%/}/project.yml"
    vectortiles_name="${project_name%.tm2}.mbtiles"
    mbtiles_file="${source_data_dir%%/}/$vectortiles_name"

    # project config will be copied to new folder because we
    # modify the source configuration of the style and don't want
    # that to effect the original file
    dest_project_dir="${dest_data_dir%%/}/$project_name"
    dest_project_config_file="${dest_project_dir%%/}/project.yml"
    cp -r "$project_dir" "$dest_project_dir"

    # project.yml is single source of truth, therefore the mapnik
    # stylesheet is not necessary
    rm "${dest_project_dir%%/}/project.xml"

    # replace external vector tile sources with mbtiles source
    # this allows developing rapidyl with an external source and then use the
    # mbtiles for dependency free deployment
    if [ -f "$mbtiles_file" ]; then
        replace_expr="s|source: \".*\"|source: \"mbtiles://$mbtiles_file\"|g"
        sed -e "$replace_expr" $project_config_file > $dest_project_config_file
    fi

    exec tessera "tmstyle://$dest_project_dir" \
        --port $port \
        --cache-size $cache_size \
        --source-cache-size $source_cache_size
done

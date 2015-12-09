#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

tiles=( '5/16/11' '6/33/22' '7/67/44' '8/134/89' '9/268/179' '10/536/358' '11/1072/716' '12/2145/1434' '13/4289/2868' '14/8580/5737' )

function generate_output() {
	local mbtiles=$1
	local provider=$2
	for ((i=0; i < ${#tiles[@]}; i++))
	do
		local input=${tiles[$i]}
		local z=$(echo $input | cut -d/ -f1)
		local x=$(echo $input | cut -d/ -f2)
		local y=$(echo $input | cut -d/ -f3)
		if [ "$provider" = "open-streets-2015-12-09" ]; then
			node ./tileInfo.js -m $mbtiles -z $z -x $x -y $y -p $provider >> open-streets.log
		else
			node ./tileInfo.js -m $mbtiles -z $z -x $x -y $y -p $provider >> mapbox.log
		fi
	done		
}

function main() {
    echo "Generating output for mapbox-streets-v6"
    generate_output "mapbox_ch_z0_z14.mbtiles" "mapbox-streets-v6"
    echo "Generating output for open-streets"
    generate_output "open_streets_ch_z0_z14.mbtiles" "open-streets-2015-12-09"
}

main
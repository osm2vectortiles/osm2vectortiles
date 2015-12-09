## TileInfo
Tool to output interesting information about a vector tile. It takes an mbtiles file and z/x/y coordinates as input.

Ouput Schema:

```bash
name: vector tile provider
tile: 10/4141/5356
features: 5000
layers: 10
classes: 20
types: 1000
[layer]
    [class]
        [type]
```

Example output:

```bash
name: mapbox-streets-v6
tile: 5-16-11
features: 369
layers: 8
classes: 5
types: 3

#admin (features: 103)
	[admin_level]
	[disputed]
	[iso_3166_1]
	[maritime]
	 no class

#country_label (features: 27)
	[code]
	[name]
	[name_de]
	[name_en]
	[name_es]
	[name_fr]
	[name_ru]
	[name_zh]
	[osm_id]
	[scalerank]
	 no class
		country
```

### Usage

```bash
Usage: tileInfo -m mapbox-streets-v6.mbtiles -z 5 -x 16 -y 11 -p mapbox-streets-v6

Options:

-h, --help                 Output usage information
-V, --version              Output the version number
-m, --mbtiles <path>       Path to mbtiles file
-x, --x <x>                X value
-y, --y <y>                Y value
-z, --z <z>                Z value
-p, --provider <provider>  Vector tile provider
```

The compare.sh script generates the tileInfo output for a given array of tiles.

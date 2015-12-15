---
layout: page
title: Create Extracts
published: true
---

If you need another extract which is not included on the [downloads page](http://osm2vectortiles.org/data/download.html), 

## Preparation

1. [Download](http://osm2vectortiles.org/data/download.html) the planet extract.
2. [Get bounding box](http://tools.geofabrik.de/calc/#type=geofabrik_standard&bbox=5.538062,47.236312,15.371071,54.954937&tab=1&proj=EPSG:4326&places=2) of your desired extract.
3. Install tilelive utility.
```bash
npm install -g tilelive
```

## Create Extract

To create the extract the tilelive-copy utility is used. It takes a bounding box and a mbtiles file as input and ouputs the extract.

Replace the bounding box in the following command with your bounding box. The first mbtiles is the input file and the second the name of the output mbtiles file.

```bash
tilelive-copy --minzoom=0 --maxzoom=14 --bounds="60.403889,29.288333,74.989862,38.5899217" world.mbtiles afghanistan.mbtiles
```

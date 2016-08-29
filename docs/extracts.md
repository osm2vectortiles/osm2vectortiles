---
layout: page
title: Create Extracts
published: true
---

# Create custom Extract

If you need an extract which is not included on the [downloads page](http://osm2vectortiles.org/downloads){:target="_blank"}, you can simply download the planet file and make your own extract. 

## Preparation

1. [Download the planet file](http://osm2vectortiles.org/downloads){:target="_blank"}
2. [Get bounding box as CSV for your desired area](http://boundingbox.klokantech.com/){:target="_blank"}
3. Install tilelive utility.

```bash
npm install -g tilelive mbtiles
```

## Create Extract

To create an extract the tilelive-copy utility is used. It takes a bounding box and a mbtiles file as input and ouputs the extract.

Replace the bounding box in the following command with your bounding box.

```bash
tilelive-copy \
    --minzoom=0 --maxzoom=14 \
    --bounds="5.9559,45.818,10.4921,47.8084" \
    planet.mbtiles my-extract.mbtiles
```

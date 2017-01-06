---
layout: page
title: Frequently Asked Questions
published: true
---

# FAQ

## Can I use the OSM2VectorTiles for commercial purposes?

We advise against using the OSM2VectorTiles MBTiles for commercial purpose due to copyright infringement claims. You should switch over to [openmaptiles.org](http://openmaptiles.org) for production setups.

You can however still use the code for commercial purposes. The project to create the vectortiles is under the [MIT license](https://tldrlegal.com/license/mit-license) and you are therefore free to take the workflow as you want and create your own vector tiles and use them commercially.
The rendered vector tiles provided as download are under the [Open Database License](https://tldrlegal.com/license/odc-open-database-license-(odbl)) the same license [OpenStreetMap is using](https://www.openstreetmap.org/copyright).
Because the data is derived from OpenStreetMap [you are required to credit OpenStreetMap](http://www.openstreetmap.org/copyright) and add the attribution "© OpenStreetMap contributors" to your maps. Apart from that OSM2VectorTiles **not** require any attribution for the rendered vector tiles.

## Will the Extracts and Planet download be updated with new OSM data?

We no longer provide updates for the vector tiles. You are able to purchase an update service from the [openmaptiles.org](http://openmaptiles.org) successor project.

## Where should I report bugs in the map?

Please report any bugs you experience on the [GitHub issue tracker](https://github.com/osm2vectortiles/osm2vectortiles/issues).

## How can I contribute to the project?

The purpose of this project is to make OSM data more accessible to anybody. Any feedback or improvement is greatly appreciated. So feel free to submit a pull request or file a bug or suggestion on [GitHub](https://github.com/osm2vectortiles/).

## What is the future Roadmap of this Project?

OSM2VectorTiles will no longer be maintained in the future. However Klokan Technologies is willing to support the successor project [openmaptiles.org](http://openmaptiles.org) in the future and provide it with regular updates.

## What are the restrictions on using the CDN?

A [public and fast vector tile server](http://osm2vectortiles.tileserver.com/v1.json) is available for everyone for testing, evaluation, development and non-commercial use.

Production setup should switch over to the successor project [openmaptiles.org](http://openmaptiles.org) which provides an updated CDN of the new vector tiles.

For extensive use it is recommended to install your own tileserver or use a paid tile service.

## What is the difference from other Vector Tile services?

We are big fans of Kartotherian and Mapzen, but believe not only the process to produce vector tiles should be open, but also the rendered data to make it really easy for everyone to create and host
their own maps.
These projects provide public vector tile servers as well, but do not provide the vector tiles as download.

## Who is behind this project?

The OSM2VectorTiles project is the finished result of the bachelor thesis of Manuel Roth and Lukas Martinelli
from the [University of Applied Sciences Rapperswil, Switzerland](http://hsr.ch/geometalab)
supported and made possible by [Klokan Technologies GmbH](http://www.klokantech.com/).
We are map enthusiasts who want to make OpenStreetMap accessible for everyone again.

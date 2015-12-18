---
layout: page
title: Frequently Asked Questions
published: true
---

# FAQ

## Can I use the OSM Vector Tiles for commercial purposes?

The project to create the vectortiles is under the [MIT license](https://tldrlegal.com/license/mit-license)
and you are therefore free to take the workflow as you want and create your own vector tiles and
use them commercially.
The rendered vector tiles provided as download are under
the [Open Database License](https://tldrlegal.com/license/odc-open-database-license-(odbl)) the same license [OpenStreetMap is using](https://www.openstreetmap.org/copyright).
Because the data is derived from OpenStreetMap [you are required to credit OpenStreetMap](http://www.openstreetmap.org/copyright) and add the attribution "© OpenStreetMap contributors" to your maps.
We ourselves do **not** require any attribution for the rendered vector tiles.

## Will the Extracts and Planet download be updated with new OSM data?

We plan to provide at least quarterly updates of the open vector tile data with the newest
sources of the OpenStreetMap planet dump.

## Where should I report bugs in the map?

Please report any bugs you experience on the [GitHub issue tracker](https://github.com/osm2vectortiles/osm2vectortiles/issues).

## How can I contribute to the project?

The purpose of this project is to make OSM data more accessible to anybody. Any feedback or improvement is greatly appreciated. So feel free to submit a pull request or file a bug or suggestion
on [GitHub](https://github.com/osm2vectortiles/).

## Can I use my custom Base Map in other GIS tools like QGIS or ArcGIS?

The [recommended raster tile server](/docs/start/) supports other
GIS clients and also supports WMTS. You can therefore use the rendered raster tiles
from our vector tiles in QGIS, ArcGIS, uDig and also different web mapping libraries
like Google Maps, Leaflet, OpenLayers, MapBox JS and ArcGIS JavaScript API.

Support for styling vector tiles in the Mapbox Vector Tile Specification is built
into Mapbox Studio and Mapbox Studio Classic.
Esri plans [to support vector tiles in ArcGIS](http://blogs.esri.com/esri/arcgis/2015/07/20/vector-tiles-preview/) and the Geometa Lab is working on a QGIS plugin for loading vector tiles directly. Map libraries like Mapbox GL JS and OpenLayers also support
direct rendering of vector tiles on the client side.

Our Open Streets tiles should be usable also in native applications on Android and iOS which uses MapBox Vector Tile specification.

## What is the future Roadmap of this Project?

Geometa Lab and Klokan Technologies are willing to support this project in the future and provide it with
regular updates. The roadmap is public and we welcome you to contribute
on the [GitHub issue tracker](https://github.com/osm2vectortiles/osm2vectortiles/issues).

## What are the restrictions on using the CDN?

A [public and fast vector tile server](http://osm2vectortiles.tileserver.com/v1.json)
is available for everyone for testing, evaluation, development and non-commercial use.

If you work on a real application we ask you kindly to [create a free access key](http://maps.klokantech.com/)
and use the vector tiles together with the access keys so we can guarantee the performance of the service.

For extensive use it is recommended to install your own tileserver or use a paid tile service.

## What is the difference from other Projects like Kartotherian or Mapzen Vector Tiles?

We are big fans of Kartotherian and Mapzen, but believe not only the process to produce vector tiles
should be open, but also the rendered data to make it really easy for everyone to create and host
their own maps.
These projects provide public vector tile servers as well, but do not provide the vector tiles downloads.
Additionally our projects has close compatibility to Mapbox Streets v5 and v6, which allows
using the superior tooling from Mapbox for creating maps (such as open-source [MapBox Studio Classic](https://www.mapbox.com/mapbox-studio-classic/)).
We are looking forward to contribute back to used open-source projects, and would love to see our tiles and styles (.tm2source) adopted in other projects like Kartotherian, and improved by the community.

## Who is behind this project?

The OSM2VectorTiles project started as a student project at Geometa Lab HSR supported and made
possible by Klokan Technologies GmbH. We are map enthusiasts who want to make OpenStreetMap
accessible for everyone again.

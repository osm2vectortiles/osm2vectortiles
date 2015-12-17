---
layout: page
title: FAQ
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

The [recommended raster tile server](/docs/display-map-with-tileserver-mapnik/) supports other
GIS clients and also supports WMTS. You can therefore use the rendered raster tiles
from our vector tiles in QGIS, ArcGIS, uDig and also different web mapping libraries
like Google Maps, Leaflet, Open Layers, MapBox JS and ArcGIS JavaScript API.

Support for styling vector tiles in the Mapbox Vector Tile Specification is built
into Mapbox Studio and Mapbox Studio Classic.
Esri plans [to support vector tiles in ArcGIS](http://blogs.esri.com/esri/arcgis/2015/07/20/vector-tiles-preview/) and the Geometa Lab is working on a QGIS plugin for supporting
vector tiles. Map libraries like Mapbox GL JS and Open Layers also support
rendering vector tiles on the client side.

## What is the future Roadmap of this Project?

Geometa Lab and Klokan Technologies are willing to support this project in the future and provide it with
regular updates. The roadmap is public and we welcome you to contribute
on the [GitHub issue tracker](https://github.com/osm2vectortiles/osm2vectortiles/issues).

## What are the restrictions on using the CDN?

A [public and fast vector tile server](osm2vectortiles.tileserver.com/v1.json)
is publicly available for everyone to use for free without any restrictions.

However if you create real application we ask you
kindly to [create a free access key](http://maps.klokantech.com/)
and use the vector tiles together with the access keys so we can guarantee the performance of the service.

## What is the difference from other Projects like Kartotherian or Mapzen Vector Tiles?

We are big fans of Kartotherian and Mapzen but believe not only the process to produce vector tiles
should be open, but also the rendered data to make it really accessible for everyone to create
their own maps.
These projects provide public vector tile servers as well but do not provide any downloads.
Additionally our projects has close compatibility to Mapbox Streets v5 and v6 which allows
using the superior tooling from Mapbox for creating maps.
We are looking forward to contribute back to projects like Kartotherian with our improved
source project and mapping files.

## Who is behind this project?

The OSM2VectorTiles project started as a study project of Geometa Lab supported and made
possible by Klokan Technologies. We are map enthusiasts who want to make OpenStreetMap
accessible for everyone again.

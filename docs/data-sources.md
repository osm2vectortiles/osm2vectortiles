---
layout: page
title: Data Sources
published: true
---

# Data Sources

The OSM Vector Tiles contain data from the different data sources
which are described below.

## OSM Planet File
The cornerstone of the entire map is OpenStreetMap data from published snapshots from [OSM Planet](http://wiki.openstreetmap.org/wiki/Planet.osm). The vector tiles contain a subset of the OSM Planet file. [Imposm3](http://imposm.org/docs/imposm3/latest/) is used with a [custom mapping file](https://github.com/osm2vectortiles/osm2vectortiles/blob/master/src/import-osm/mapping.yml) to import the OSM data into the PostGIS database.

Imposm3 creates the following tables in the PostGIS database.

| Table Name                       | Geometry Type | Description                         |
| -------------------------------- | ------------- | ----------------------------------- |
| admin                            | linestring    | Administrative boundaries           |
| buildings                        | polygon       | Building shapes                     |
| landusages                       | polygon       | Human use of land                   |
| places                           | point         | Populated settlements               |
| roads                            | linestring    | Roads, tracks and paths             |
| aero_lines                      | linestring    | Airports and aviation-related items |
| aero_polygons                   | polygon       | see aero_lines                     |
| barrier_lines                   | linestring    | Movement blocking structures        |
| barrier_polygons                | polygon       | see barrier_lines                  |
| housenumbers_points             | point         | Address information about houses    |
| housenumbers_polygons           | polygon       | see housenumbers_points            |
| poi_points                      | point         | Point of interest                   |
| poi_polygons                    | polygon       | see poi_points                     |
| water_lines                     | linestring    | Lakes and rivers                    |
| water_polygons                  | polygon       | see water_lines                    |

## OpenStreetMapData

[Water polygons](http://openstreetmapdata.com/data/water-polygons) from OpenStreetMapData were used for the ocean parts of the world.
This data set ensures that the water polygons work well together with other OpenStreetMap
data and splits big water polygons into multiple pieces for performance.

| Table Name                               | Geometry Type | Description              |
| ---------------------------------------- | ------------- | ------------------------ |
| osm\_ocean\_polygons                     | polygon       | Ocean, seas, large lakes |

## Natural Earth

The Natural Earth data set is only used for the lower zoom levels. The imported Natural Earth data results in more than 100 tables, but only a few are relevant for our use case.
The following Natural Earth tables are used:

| Table Name                                                                                                                | Geometry Type |
| ------------------------------------------------------------------------------------------------------------------------- | ------------- |
| ne\_110m\_admin\_0\_boundary\_lines\_land                                                                                       | linestring    |
| ne\_50m\_admin\_0\_boundary\_lines\_land                                                                                        | linestring    |
| ne\_10m\_admin\_0\_boundary\_lines\_land                                                                                        | linestring    |
| ne\_50m\_admin\_1\_states_provinces\_lines                                                                                     | linestring    |
| ne\_10m\_admin\_1\_states_provinces\_lines\_shp                                                                                 | linestring    |
| ne\_10m\_admin\_0\_boundary\_lines\_disputed\_areas                                                                              | linestring    |
| ne\_110m\_lakes                                                                                                             | polygon       |
| ne\_50m\_lakes                                                                                                              | polygon       |
| ne\_10m\_lakes                                                                                                              | polygon       |


## Custom Curated Labels

The placement and importance of labels of countries, states and seas [matters](https://axismaps.github.io/thematic-cartography/articles/labeling.html) and is important to get right. Data from the [Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API) is converted into GeoJSON and manually edited and enhanced with a label rank. For sea labels custom lines have been drawn to place the label along this line.

| Table Name                  | Geometry Type | Description   |
| --------------------------- | ------------- | ------------- |
| custom\_seas                | point         | Marine names  |
| custom\_countries           | point         | Country names |
| custom\_states              | point         | State names   |


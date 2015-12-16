---
layout: page
title: Data Sources
published: true
---

# Data Sources

The OSM Vector Tiles contain data from the following data sources.

## OSM Planet File
The cornerstone of the entire map is OpenStreetMap data from published snapshots from [OSM Planet](http://wiki.openstreetmap.org/wiki/Planet.osm). The vector tiles contain a subset of the OSM Planet file. [Imposm3](http://imposm.org/docs/imposm3/latest/) is used with a [custom mapping file](https://github.com/osm2vectortiles/osm2vectortiles/blob/master/src/import-osm/mapping.yml) to import the OSM data into the PostGIS database.

More information about the [layer reference](/docs/imposm-schema.html)

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
| ne_110m_admin_0_boundary_lines_land                                                                                 | linestring    |
| ne_50m_admin_0_boundary_lines_land                                                                                  | linestring    |
| ne_10m_admin_0_boundary_lines_land                                                                                  | linestring    |
| ne_50m_admin_1_states_provinces_lines                                                                               | linestring    |
| ne_10m_admin_1_states_provinces_lines_shp                                                                          | linestring    |
| ne_10m_admin_0_boundary_lines_disputed_areas                                                                       | linestring    |
| ne_110m_lakes                                                                                                           | polygon       |
| ne_50m_lakes                                                                                                            | polygon       |
| ne_10m_lakes                                                                                                            | polygon       |


## Custom Curated Labels

The placement and importance of labels of countries, states and seas [matters](https://axismaps.github.io/thematic-cartography/articles/labeling.html) and is important to get right. Data from the [Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API) is converted into GeoJSON and manually edited and enhanced with a label rank. For sea labels custom lines have been drawn to place the label along this line.

| Table Name                  | Geometry Type | Description   |
| --------------------------- | ------------- | ------------- |
| custom\_seas                | point         | Marine names  |
| custom\_countries           | point         | Country names |
| custom\_states              | point         | State names   |


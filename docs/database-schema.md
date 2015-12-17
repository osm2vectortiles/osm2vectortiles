---
layout: page
title: Database Schema and Layers
published: true
---

# Database Schema

The layer schema tries to stay compliant to Mapbox Streets v6 and Mapbox Streets v5.
The detailed documentation on which database tables are mapped to which feature classes, can be found in the following sections.

## Aeroways, Barriers and Landusages

For some layers linestring and polygon data needs to be mapped into
tables. The different geometries are then both rendered as vector
linestrings. The landing strips of airports for example might be a
linestring or polygon.

![Layers for aeroways, barriers and landusages](/media/aero_barrier_landusage_layer.png)

## Administrative Borders

The administrative area on lower zoom levels is entirely from Natural
Earth data. Only at higher zoom levels where details are more important
the OSM borders are rendered.

Natural Earth provides data in several generalization levels. The table
with highest generalization is used on the lowest zoom levels and on
higher zoom levels the less generalized tables.

![Layers for administrative areas](/media/admin_layer.png)

## Roads, Bridges and Tunnels

Roads are split up into normal roads, tunnels and bridges after a
certain zoom level. `z_order` and `layer` attributes are used to order
the geometries on the right z axis. Road labels however will always
contain data for tunnels, bridges and normal roads therefore one table
that is filtered into different views at higher zoom levels is the best
approach.

![Layers for roads, tunnels and bridges](/media/road_layer.png)

## Points of Interest

Most POIs are in fact points, but buildings tagged with POI attributes
are often polygons, which is why tables for both points and polygons are
created.

The `localrank` and `scalerank` of the `#poi_label` layer are calculated
from the `type` and `area` attributes. The `address` field is pulled
together from the various address attributes on the tables (`street`,
`housenumber`, `place`, `city`, `postcode` and `country`).
  
![Point of interest label layer](/media/poi_layer.png)

Water
-----

Water bodies for lower zoom levels are taken from Natural Earth data
while lakes and rivers are from OpenStreetMap. Big rivers often consist out of
a water polygons while smaller rivers are only water ways.

![Water bodies and river layers](/media/water_layer.png)

Places
------

Places are names of cities and villages. To calculate the importance of
a city the scalerank of the most important cities from Natural Earth
data is merged into the OpenStreetMap data set. For places that do not have a
scalerank value a dynamic value is calculated based on the population.

![Place label layer](/media/place_layer.png)

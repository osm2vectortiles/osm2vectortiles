---
layout: page
title: Imposm Mapping Schema
published: true
---

# Imposm Mapping Schema

Imposm3 allows to do alot of work up front.
We decided to use an explicit mapping instead of an implicit one with the advantage
that we always know exactly which values are in the database.

The tables are modelled pretty close to the layer who are using it. This is for performance
purposes.

## Schema

![Imposm Mapping Schema](/media/table_to_layer_mapping.png)

## Used Keys

Most OSM key value pairs are used in the `poi_points` and `poi_polygons` tables.

![Imposm Mapping Schema](/media/mapping_graph.png)

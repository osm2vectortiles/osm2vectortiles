---
layout: page
title: Imposm Mapping Schema
published: true
---

# Imposm Mapping Schema

Imposm3 allows to do alot of work up front.
We decided to use an explicit mapping instead of an implicit one with the advantage
that we always know exactly which values are in the database.

The tables are modelled pretty close to the layer reference for performance reasons.

## Mapping File

We started of with the default imposm mapping schema and modified it extensively to fit our needs.
We welcome you to
[explore the mapping file](https://github.com/osm2vectortiles/osm2vectortiles/blob/master/src/import-osm/mapping.yml)
and take the mappings that you need for your project,
as alot of knowledge is contained in the mapping file.

## Used Keys

Most OSM key value pairs are used in the `poi_points` and `poi_polygons` tables.

![Imposm Mapping Schema](/media/mapping_graph.png)

## Mapping Example

Example mapping for the landusages table.

```yaml
tables:
  landusages:
    type: polygon
    fields:
    - name: osm_id
      type: id
    - name: geometry
      type: geometry
    - name: type
      type: mapping_value
    mapping:
      landuse:
      - allotments
      - farm
      - farmland
      - farmyard
      - orchard
      - greenhouse_horticulture
      - plant_nursery
      - vineyard
      - grass
      - grassland
      - meadow
      - industrial
      - park
      - village_green
      - recreation_ground
      - forest
      - cemetery
      - beach
      leisure:
      - park
      - playground
      - dog_park
      - national_reserve
      - nature_reserve
      - golf_course
      - common
      - garden
      - recreation_ground
      - sports_centre
      - pitch
      natural:
      - glacier
      - sand
      - wood
      - scrub
      - wetland
      - mud
      wetland:
      - marsh
      - swamp
      - tidalflat
      - bog
      amenity:
      - hospital
      - school
      - college
      - university
      cemetery:
      - __any__
      boundary:
      - national_park
      tourism:
      - zoo
      - camp_site
```

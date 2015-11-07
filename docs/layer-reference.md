---
layout: page
title: Layer Reference
published: true
---

# Layer Reference

Guide about the data inside the vector tiles to help you with styling.

## #landuse

This layer includes polygons representing both land-use and land-cover.

It’s common for many different types of landuse/landcover to be overlapping, so the polygons in this layer are ordered by the area of their geometries to ensure smaller objects will not be obscured by larger ones. Pay attention to use of transparency when styling - the overlapping shapes can cause muddied or unexpected colors.

### Classes

The main field used for styling the landuse layer is `class`.
Class is a generalization of the various OSM values described as `types`.

| Class              | Aggregated Types
|--------------------|-----------------------------------------------------------------
|`agriculture`       | `orchard`, `farm`, `farmland`, `farmyard`, `allotments`, `vineyard`, `plant_nursery`
|`cemetery`          | `cemetery`, `christian`, `jewish`
|`glacier`           | `glacier`
|`grass`             | `grass`, `grassland`, `meadow`
|`hospital`          | `hospital`
|`industrial`        | `industrial`
|`park`              | `park`, `dog_park`, `common`, `garden`, `golf_course`, `playground`, `recreation_ground`, `nature_reserve`, `national_park`, `village_green`, `zoo`
|`pitch`             | `athletics`, `chess`, `pitch`
|`sand`              | `sand`
|`school`            | `school`, `college`, `university`
|`scrub`             | `scrub`
|`wood`              | `wood`, `forest`,

## #water

This is a simple polygon layer with no differentiating types or classes. Water bodies are filtered
and simplified according to scale - only oceans and very large lakes are shown at the lowest zoom
levels, while smaller and smaller lakes and ponds appear as you zoom in.

## #waterway

| Column             | Types
|--------------------|-----------------------------------------------------------------
|`name`              | Name of the water way. Translations are available in the `name_en`, `name_de`, `name_fr`, `name_es`, `name_ru`, `name_zh` fields.


### Types

The `type` column can can contain one of the following types:

- `ditch`
- `stream`
- `stream_intermittent`
- `river`
- `canal`
- `drain`
- `ditch`

---
layout: page
title: Layer Reference
published: true
---

# Layer Reference

This is an in-depth guide the data inside the Mapbox Streets vector tile source to help with styling. 

## #landuse

This layer includes polygons representing both land-use and land-cover.

It’s common for many different types of landuse/landcover to be overlapping, so the polygons in this layer are ordered by the area of their geometries to ensure smaller objects will not be obscured by larger ones. Pay attention to use of transparency when styling - the overlapping shapes can cause muddied or unexpected colors.

### Classes

The main field used for styling the landuse layer is `class`.
Class is a generalization of the various OSM values described as `types`.


| Value              | Types
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

## #waterway

The waterway layer contains rivers, streams, canals, etc represented as lines.

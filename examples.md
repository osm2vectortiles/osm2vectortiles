---
layout: page
title: Examples
published: true
---

# Examples using OSM2VectorTiles

## MapHub

[MapHub.net](https://maphub.net/) by [hyperknot](https://hyperknot.com/)
allows you to create interactive customizable maps
to organize your own geo-data. It is using OSM2VectorTiles based basemaps to provide
a variety of basemaps to choose from for it's users.

[![MapHub.net basemaps](/media/maphub.png)](https://maphub.net/)

## NOAA

NOAA created a completely offline application which is installed on a small Intel NUC hardware and used now in the airplanes after natural disasters (floods, hurricanes, etc) in the USA by pilots as an aid for the planned flying rounds to capture imagery of the affected area properly.

They web app is accessed by the pilots from their iPad via their local WiFi access point.
The offline MapBox GL JS app is used together with [tileserver-php](https://github.com/klokantech/tileserver-php), vector tiles from OSM2VectorTiles and raster tiles from [MapTiler](https://www.maptiler.com/).

<iframe width="560" height="315" src="https://www.youtube.com/embed/t8AXu0Fev0Q" frameborder="0" allowfullscreen></iframe>

## GeoPortal of Mecklenburg County GIS

The [GeoPortal of Mecklenburg County GIS](http://mcmap.org/geoportal/) is using OSM2VectorTiles in combination
with custom data. The source code is [available on GitHub](https://github.com/tobinbradley/Mecklenburg-County-GeoPortal) and the [accompanying blog post can be read
on Tobin Bradley's homepage](http://fuzzytolerance.info/blog/2016/03/21/GeoPortal-migrated-to-Mapbox-GL-JS/).

<iframe width="560" height="315" src="https://www.youtube.com/embed/DtEIu-h2FQo" frameborder="0" allowfullscreen></iframe>


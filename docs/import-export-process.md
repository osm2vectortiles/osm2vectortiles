---
layout: page
title: Import and Export Process
published: true
---

# Import and Export Process

### Import

In the import process all [data sources](/docs/data-sources.html) get imported into a single PostGIS database. The figure below shows which data source gets imported with which import tool.

![Import Step](/media/import_package_flow.png)

The import sql container adds helper sql functions, which are used inside the [data style](https://github.com/osm2vectortiles/osm2vectortiles/blob/master/open-streets.tm2source/data.yml).

### Export

For generating the vector tiles the tilelive tool [tl](https://github.com/mojodna/tl) is used which wraps around Mapnik. The data style defines all feature sets (layers) and is transformed into a Mapnik XMLstylesheet by the tilelive-tm2source provider. Tilelive-bridge calls Mapnik with the generated stylesheet and  hands  the  generated  data  over  to node-mbtiles, which  stores  the  vector  tiles  in  a MBTiles container.

![Export Step](/media/export_package_flow.png)

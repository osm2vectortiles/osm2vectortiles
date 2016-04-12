# OSM2VectorTiles tm2source Project

[Mapbox Steets v7](https://www.mapbox.com/developers/vector-tiles/mapbox-streets-v7/) compatible data source.

## Requirements

See [osm2vectortiles documentation](https://github.com/geometalab/osm2vectortiles) for details.

## Layers

Because this data source is compatible with Mapbox Streets v5 all layers your can find in Mapbox Streets v5 are also available in this source. 
For more information, please check out the documentation of [Mapbox Streets v5](https://www.mapbox.com/developers/vector-tiles/mapbox-streets-v5/)

## Editing

If you want to edit this data source, you need some OSM data on your local machine. Follow the documentation of the [osm2vectortiles project](https://github.com/geometalab/osm2vectortiles) to set everything up.

- Install the latest [Mapbox Studio Classic](https://www.mapbox.com/mapbox-studio-classic/)
- Clone this repository and edit the data.yml file with connection information for your postgis database.

```bash
host: <your host>
port: <your port>
dbname: <your dbname>
password: <your password>
```
- Add this repository as a data source in Mapbox Studio Classic. Now, you should see your data as "x-ray" outlines. 

To see the data in style:
- Open any style in Mapbox Studio Classic and change source to this repository under layers.

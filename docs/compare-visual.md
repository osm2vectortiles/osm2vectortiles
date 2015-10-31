## Compare Open Streets with Mapbox Streets

Using the `compare-visual` component you are able to compare the
rendered raster map from [open-streets.tm2source](https://github.com/geometalab/open-streets.tm2source)
with maps made from [Mapbox Streets](https://www.mapbox.com/developers/vector-tiles/mapbox-streets-v5).

The tool is an adapted version of http://bl.ocks.org/milkbread/7430798 with a reverse proxy to
the `serve` component.

![Compare two Maps](figures/compare-two-maps.gif)

## Prepare

Export a new MBTiles from the database with the `export` container.

```
docker-compose up export
```

Now make sure you have a style project in the `export` folder together with the MBTiles
file otherwise you will only see X-Ray styles.

```
git clone https://github.com/mapbox/mapbox-studio-osm-bright.tm2 tiles.tm2
```

## Run

Now start up the `compare-visual` container which will depend on `server` to render
the MBTiles with the correct styles.

```
docker-compose up compare-visual
```

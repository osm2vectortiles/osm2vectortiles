# Tileserver

Render raster data from vector tiles and style projects
on the fly with the help of [tessera](https://github.com/mojodna/tessera).

You plug in your vector tiles and style projects and
you have a hosted tileserver.

## Kitematic Usage

## Docker Usage

Mount your `mbtiles` files and `tm2` style projects into the `/data` volume.
If your `mbtiles` sources are named the same as your `tm2` project the
script will automatically replace the source specified in the `data.yml`
of your `tm2` project with the according `mbtiles` source.

Give the current folder contains the following files and directories.

```
├── countries.tm2
└── countries.mbtiles

```

You can run a docker container.

```
docker run -p 8080:8080 -v $(pwd):/data osm2vectortiles/tileserver
```

No visit `localhost:8080` to see a leaflet map of the rendered raster tiles.


**Why tessera?**

Fastest way to get up and running to serve different sources.

## Tessera

Serve up tm2source directly.

```bash
tessera tmsource://./vector-tiles-sample/countries.tm2source
```

## Docker

We packaged tessera in a docker container.

Serve up tm2source directly.

```bash
docker run -v $(pwd)/vector-tiles-sample:/data -p 8080:8080 tessera tmsource://data/countries.tm2source
```

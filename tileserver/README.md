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

Original source URI.

```
mapbox:///klokantech.97cbd1e1
```

Will be changed to the `mbtiles` source of the same name.

```
mbtiles:///data/countries.mbtiles
```

Give the current folder contains the following files and directories.

```bash
├── countries.tm2
└── countries.mbtiles
```

You can run a docker container.

```
docker run -p 8080:8080 -v $(pwd):/data osm2vectortiles/tileserver
```

Visit `localhost:8080` to see a [leaflet](http://leafletjs.com/)
map of the rendered raster tiles.

Contains the vectortiles-server and rastertiles-server.

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

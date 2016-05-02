# import-external

The **import-external** component is responsible for importing **all data that is not
mapped directly from OSM** into the PostGIS database.

## Usage

### Docker

To use **import-external** you only need the *osm2vectortiles/import-external* Docker image,
all the data sources are baked into the Docker container already.

You need to run **import-external** before you import OSM data with **import-osm** and you only
need to run the import once!

```
docker-compose run import-external
```

## Flow Diagram

**import-external** takes data from three data sources and imports them into PostGIS.

![Flow Diagram](import-external-flow-diagram.png)

### Details

![Flow Diagram](import-external-detail-flow-diagram.png)

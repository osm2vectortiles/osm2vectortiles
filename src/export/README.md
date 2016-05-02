# export

The **export** component is responsible for rendering vector tiles using `osm2vectortiles.tm2source` and the **postgis** component.
You can run **export** together with a message queue **rabbitmq** or standalone for smaller extracts where you don't need to divide the work into several parts.

## Usage

### Create extract

Adjust the `BBOX` env var in the `export` container section of `docker-compose.yml` to fit the extract you want to create.

```bash
docker-compose run export
```

### Run as worker

If you run **export** in worker mode you need to:

1. Have a RabbitMQ server **rabbitmq** up and running
2. Configure S3 access in `docker-compose.yml`

```bash
docker-compose scale export-worker=2
```

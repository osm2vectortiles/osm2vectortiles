# OSM Import into PostGIS

Infrastructure to create a docker based OSM Postgis database
to create vector tiles from.

The database is separated from the import process. You can switch
out the database container with a existing database.

# Import

## Run the PostGIS container

Mount the folder where the database data should be stored in
and start the database container.

On first startup the container will automatically create a OSM database from
the modified PostGIS template containing the additional hstore extension and
the [postgis-vt-util](https://github.com/mapbox/postgis-vt-util) functions from Mapbox.

```bash
docker run --name postgis \
    -v /data/pgdata:/var/lib/postgresql/data \
    -d osm2vectortiles/postgis
```

### Customize OSM database

You can configure the database settings via environment variables.

| Env            | Default   | Description             |
|----------------|-----------|-------------------------|
| `OSM_DB`       | `osm`     | Database name           |
| `OSM_USER`     | `osm`     | Database owner          |
| `OSM_PASSWORD` | `osm`     | Database owner password |

More configuration options are supported through the
[official Postgres Docker image](https://hub.docker.com/_/postgres/) and
the [mdillon/postgis](https://hub.docker.com/r/mdillon/postgis/) image.

| Env                 | Default                    | Description                |
|---------------------|----------------------------|----------------------------|
| `POSTGRES_USER`     | `postgres`                 | Database admin             |
| `POSTGRES_PASSWORD` | no password                | Database admin password    |
| `PGDATA`            | `/var/lib/postgresql/data` | Location of database files |

## Run the Imposm  Import

Download OSM areas from [Geofabrik](http://download.geofabrik.de/)
or [Mapzen](https://mapzen.com/data/metro-extracts).

Example of downloading a Metro extract of Zurich Switzerland.

```bash
wget https://s3.amazonaws.com/metro-extracts.mapzen.com/zurich_switzerland.osm.pbf
```

Mount the import data directory containing the PBF files to import
and the imposm cache directory to speed up multiple runs.

You also need to link our previously created `postgis` database container
as `db`.
The container will use a custom mapping.json to import the data into
the `db` database container.

```bash
docker run --rm --name imposm \
    -v /data/import:/data/import \
    -v /data/cache:/data/cache \
    --link postgis:db \
    osm2vectortiles/imposm3
```

This will take a long time depending on the data you want to import.

### Customize Import

You can configure the database settings where the data should be imported
as well as imposm settings.

| Env                | Default                   | Description             |
|--------------------|---------------------------|-------------------------|
| `OSM_DB`           | osm                       | Database name           |
| `OSM_USER`         | osm                       | Database owner          |
| `OSM_PASSWORD`     | osm                       | Database owner password |
| `IMPORT_DATA_DIR`  | /data/import              | PBF import directory    |
| `IMPOSM_CACHE_DIR` | /data/cache               | Imposm cache directory  |
| `IMPOSM_BIN`       | /usr/src/app/imposm3      | Imposm executable path  |
| `MAPPING_JSON`     | /usr/src/app/mapping.json | Imposm mapping config   |

## Develop tm2source Projects with Mapbox Container

To develop our tm2source projects you can use Mapbox in a Docker container on a more powerful server
or simply to ensure you develop in the same environment.
To access the container from outside you should expose port 3000.

You should map the directory where you keep your `tm2source` projects to `/data/projects` and
open it in Mapbox Studio.

```bash
docker run --rm --name mapbox \
    -v /data/projects:/data/projects \
    -p 3000:3000 \
    --link postgis:db \
    osm2vectortiles/mapbox-studio-classic
```

Configuring the PostGIS hostname and port in tm2source layers is difficult without inspecting the linked
container. Therefore the easiest way is to expose the port 5432 on the PostGIS container and connect
to it directly.

## Export Tiles

```
docker run --rm \
	-v /data/export3:/data/export
	-v /home/core/kartotherian/osm-bright.tm2source:/project \
	-e MIN_ZOOM=0 \
	-e MAX_ZOOM=12 \
	-e BBOX="5.6470 45.6601 10.7886 48.0487" \
	--name export \
	--link postgis:db \
	osm2vectortiles/tilelive
```

# Usage Documentation

If you've gotten this far, you've already explored the [documentation](http://osm2vectortiles.org/docs/) and likely have imported
a smaller extract of the planet. If you're looking to adapt OSM2VectorTiles for your own purposes
or run the process yourself this usage documentation is for you. Many thanks to @stirringhalo for much of the usage documentation.

## Requirements

The entire project is structured components using Docker containers
to work together. Ensure you meet the prerequisites for running the
OSM2VectorTiles workflow.

- Install [Docker](https://docs.docker.com/engine/installation/)
- Install [Docker Compose](https://docs.docker.com/compose/install/)
- Setup a S3 bucket (or compatible object storage)

We assume a single machine setup for this purpose and later go into detail
how to run the workflow in a distributed manner.

**Hardware Requirements:**

You can render small areas with OSM2VectorTiles on your local machine.
However to run the workflow at global scale you need significant infrastructure.

- 500GB disk space (150GB PostGIS, 30GB planet dump, 50GB imposm3 cache, 50 GB final MBTiles)
- 16GB+ RAM recommended (up until 50 GB RAM for PostGIS)
- 8+ CPU cores (up until 16-40 cores) for rendering vector tiles and PostGIS calculations

## High-level Procedure

The architecture of the project is structured into the import phase (ETL process),
the changed tiles detection phase and the export phase (render vector tiles).

If you run the distributed workflow yourself, the following steps take place.
A detailed explanation follows afterwards.

1. Import external data sources into PostGIS
2. Import OSM PBF into PostGIS
3. Create a low level global extract from z0 to z8
4. Generate jobs to render entire planet and submit them to message queue (RabbitMQ)
5. Start rendering processes to work through submitted jobs
6. Merge job results together into previous low level extract resulting in the final planet MBTiles
7. Create country and city extracts from MBTiles

![Workflow structured into components](/src/etl_components.png)

### Component Overview

Documentation for each component can be find in the respective source directory.

**Import Components**

- **[import-external](/src/import-external)**: Import all data that is not directly form OpenStreetMap (NaturalEarth, OpenStreetMapData, custom data files)
- **[import-osm](/src/import-osm)**: Import OpenStreetMap planet files into PostGIS using imposm3
- **[import-sql](/src/import-sql)**: Provision and generate SQL used in the different layers. Contains most of the SQL logic.

**Export Components**

- **[export-worker](/src/export-worker)**: Responsible for rendering vector tiles using the vector data source **[osm2vectortiles.tm2source](/osm2vectortiles.tm2source)**. Exports can be run together with a message queue like RabbitMQ or standalone for smaller extracts where it is not necessary to divide the work into several parts.
- **[merge-jobs](/src/merge-jobs)**: Merges results of distributed rendering together into a single planet MBTiles file.

**Changed Tile Detection Components**

- **[changed-tiles](/src/changed-tiles)**: Calculate list of changed tiles
- **[generate-jobs](/src/generate-jobs)**: Responsible for creating JSON jobs for rendering the planet initially or jobs for updating the planet.
- **[update-osm-diff](/src/import-osm)**: Download diffs from OpenStreetMap based on imported planet file.
- **[import-osm-diff](/src/import-osm)**: Import OpenStreetMap diff file created by **update-osm-diff**.
- **[merge-osm-diff](/src/import-osm)**: Merge latest diff file into the old planet file.

## Processing Steps

### Prepare

1. Clone repository `git clone https://github.com/osm2vectortiles/osm2vectortiles.git && cd osm2vectortiles`.
2. If you want to build the containers yourself execute `make fast` or `make`. Otherwise you will use the public prebuilt Docker images by default.
3. Start and initialize database `docker-compose up -d postgis`
4. Import external data sources `docker-compose run import-external`

### Import OSM

**Download planet file or extract** from [Planet OSM](http://planet.osm.org/) or [Geofabrik](https://www.geofabrik.de/data/download.html) and store it in `import` folder.

```bash
wget http://planet.osm.org/pbf/planet-latest.osm.pbf
```

**Import OSM** into PostGIS. Since the import happens in diff mode this can take up to 14hrs for the full planet.

```bash
docker-compose run import-osm
```

**Provision SQL** needed to render the different layers.

```bash
docker-compose run import-sql
```

### Create Extract using Local Worker

You are now able to use a single local worker to render a extract. This can be used to create a extract
for a specific reason or generating low level vector tiles.

1. First **choose a specific bounding box** or export global bounding box from http://tools.geofabrik.de/calc/.
2. **Run the local export** which will store the resulting MBTiles in `export/tiles.mbtiles`

```bash
# Create low level extract from z0 to z8 for entire planet
docker-compose run \
  -e BBOX="-180, -85, 180, 85" \
  -e MIN_ZOOM="0" \
  -e MAX_ZOOM="8" \
  export
# Create extract for Albania from z10 to z14
docker-compose run \
  -e BBOX="19.6875,40.97989806962015,20.390625,41.50857729743933" \
  -e MIN_ZOOM="10" \
  -e MAX_ZOOM="14" \
  export
```

### Distributed Planet Export

You need to distribute the jobs to multiple workers for rendering the entire planet.
To work with the message queues and jobs we recommend using [pipecat](https://github.com/lukasmartinelli/pipecat).

**Start up message queue server**. The message queue server will track the jobs and results.

```bash
docker-compose up -d rabbitmq
```

**Divide the planet into jobs** from z8 down to z14 and publish the jobs to RabbitMQ.
To render the entire planet choose the top level tile `0/0/0` and choose job zoom level `8`.

```bash
docker-compose run \
  -e TILE_X=0 -e TILE_Y=0 -e TILE_Z=0 \
  -e JOB_ZOOM=8 \
  generate-jobs
```

**Scale up the workers** to render the jobs. Make sure the `BUCKET_NAME`, `AWS_ACCESS_KEY`, `AWS_SECRET_ACCESS_KEY` and `AWS_S3_HOST` are configured correctly in order for the worker to upload the results to S3.

```bash
docker-compose scale export-worker=4
```

Watch progress at RabbitMQ management interface. Check the exposed external Docker port of the RabbitMQ management interface at port `15672`.


### Merge MBTiles

Please take a look at the component documentation of **[merge-jobs](/src/merge-jobs)**.
If you are using a public S3 url merging the job results is fairly straightforward.

1. Ensure you have `export/planet.mbtiles` file present to merge the jobs into. Reuse a low level zoom extract generated earlier or download an existing low level zoom extract from http://osm2vectortiles.org/downloads/.
2. **Merge jobs** into planet file

```bash
docker-compose run merge-jobs
```

### Apply Diff Updates

Updates are performed on a rolling basis, where diffs are applied.
At this stage we assume you have successfully imported the PBF into the database
and rendered the planet once.

**Download latest OSM changelogs**. If you are working with the planet remove the `OSM_UPDATE_BASEURL` from the `environment` section in `update-osm-diff`. If you are using a custom extract from Geofabrik you can specify a custom update url there.

Download latest changelogs **since the last change date of the planet.pbf**.

```bash
docker-compose run update-osm-diff
```

Now **import the downloaded OSM diffs** in `export/latest.osc.gz` into the database. This may take up to half a day. 

```bash
docker-compose run import-osm-diff
``` 

After that you have successfully applied the diff updates to the database and you can either rerender the entire planet or just the tiles that have changed.

After importing the diffs **you can reapply the diffs to the original PBF** file to keep it up to date.

```bash
docker-compose run merge-osm-diff
```

### Render Diff Updates

**Calculate the changed tiles** since the last diff import. This will store the changed tiles in `export/tiles.txt`.

```bash
docker-compose run changed-tiles
```

**Create batch jobs** from the large text file and publish them to RabbitMQ.

```bash
docker-compose run generate-diff-jobs
```

**Now schedule the workers** again (similar to scheduling the entire planet) and **merge the results**.
```bash
docker-compose scale export-worker=4
docker-compose run merge-jobs
```

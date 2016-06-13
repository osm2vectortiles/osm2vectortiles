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

1. `git clone https://github.com/osm2vectortiles/osm2vectortiles.git`
2. `cd osm2vectortiles`
3. If you want to build the containers yourself execute `make fast` or `make`. Otherwise you will reuse the public prebuilt Docke rimages.
4. Start and initialize database `docker-compose up -d postgis`
5. Import external data sources `docker-compose run import-external``

### Import OSM

1. Download planet file or extract from [Planet OSM](http://planet.osm.org/) or [Geofabrik](https://www.geofabrik.de/data/download.html) and store it in `import` folder.
  ```
  wget http://planet.osm.org/pbf/planet-latest.osm.pbf
  ```
2. Import OSM with `docker-compose run import-osm`. Since the import happens in diff mode this can take up to 14hrs for the full planet
3. Provision SQL needed to render the different layers with `docker-compose run import-sql`

### Create Extract using Local Worker

You are now able to use a single local worker to render a extract. This can be used to create a extract
for a specific reason or generating low level vector tiles.

1. Edit the `docker-compose.yml`.
  1. If you want to create a low level extract from z0 to z8 set  `BBOX="-180, -85, 180, 85"` and `MIN_ZOOM=0` and `MAX_ZOOM=8`.
  2. If you want to render only a specific reson set `BBOX` to your desired bounding box and `MAX_ZOOM=14`.
2. Run `docker-compose export` which will store the resulting MBTiles in `export/tiles.mbtiles`


### Distributed Planet Export

You need to distribute the jobs to multiple workers for rendering the entire planet.
To work with the message queues and jobs we recommend using [pipecat](https://github.com/lukasmartinelli/pipecat).

1. Divide the planet into jobs from z8 down to z14. This will take some time. Save the `jobs.json` file for later so you don't need to regenerate if you need to do a full re-rendering.
  ```
  docker-compose run generate-jobs python generate_jobs.py pyramid 0 0 0 --job-zoom=8 > jobs.jso
  ```
2. Start up message queue server with `docker-compose up -d rabbitmq`
3. Now configure the message queue endpoint to the host where your message queue is running. By default the message queue is exposed on the local port `5672`. If you are running it on a separate server you need to change the host.
  ```
  export AMQP_URI=amqp://osm:osm@localhost:5672/
  ```
5. Install pipecat ([installation docs](https://github.com/lukasmartinelli/pipecat#install))
   1. `wget -O pipecat https://github.com/lukasmartinelli/pipecat/releases/download/v0.2/pipecat_linux_amd64`
   2. `chmod +x pipecat`
6. `cat jobs.json | ./pipecat publish jobs`
7. Scale up the workers `docker-compose scale export-worker=4`
8. Watch progress at RabbitMQ management interface at http://localhost:15672

### Merge MBTiles

Please take a look at the component documentation of **[merge-jobs]((/src/merge-jobs))**.
If you are using a public S3 url merging the job results is fairly straightforward.

1. Ensure you have `export/planet.mbtiles` file present to merge the jobs into. Reuse a low level zoom extract generated earlier or download an existing low level zoom extract from http://osm2vectortiles.org/downloads/
2. Merge jobs into planet file `docker-compose run merge-jobs`

TODO: Check how it works with mock s3.

### Apply Diff Updates

Updates are performed on a rolling basis, where diffs are applied.
At this stage we assume you have successfully imported the PBF into the database
and rendered the planet once.

1. Download latest OSM changelogs.
  1. If you are working with the planet remove the `OSM_UPDATE_BASEURL` from the `environment` section in `update-osm-diff`.
  2. Execute `docker-compose run update-osm-diff` to download latest changelogs **since the last change date of the planet.pbf**.
2. Now import the downloaded OSM diffs in `export/latest.osc.gz` into the database with `docker-compose run import-osm-diff`. This may take up to half a day. 

After that you have successfully applied the diff updates to the database and you can either rerender the entire planet or just the tiles that have changed.


### Render Diff Updates

1. Calculate the changed tiles since the last diff import with `docker-compose up changed-tiles`. This will store the changed tiles in `export/tiles.txt`.
2. TODO: Create job list
3. Now schedule the jobs (similar to scheduling the entire planet).

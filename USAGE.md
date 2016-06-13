# Usage Documentation

If you've gotten this far, you've already explored the [documentation](http://osm2vectortiles.org/docs/) and likely have imported
a smaller extract of the planet. If you're looking to adapt OSM2VectorTiles for your own purposes
or run the process yourself this usage documentation is for you.

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

![/src/etl_components.png](Workflow structured into components)

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

- **[update-osm-diff](/src/import-osm-diff)**: Download diffs from OpenStreetMap based on imported planet file.
- **[import-osm-diff](/src/import-osm-diff)**: Import OpenStreetMap diff file created by **update-osm-diff**.
- **[merge-osm-diff](/src/merge-osm-diff)**: Merge latest diff file into the old planet file.
- **[changed-tiles](/src/changed-tiles)**: Calculate list of changed tiles
- **[generate-jobs](/src/generate-jobs)**: Responsible for creating JSON jobs for rendering the planet initially or jobs for updating the planet.

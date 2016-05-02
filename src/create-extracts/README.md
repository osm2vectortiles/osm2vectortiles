# create-extracts

The **create-extracts** component is responsible for cutting out specific country and
city extracts as specified in the CSV files from the latest planet MBTiles file.

![Flow Diagram](create-extracts-flow-diagram.png)

## Usage

### Docker

To use **create-extracts** inside the Docker Compose workflow you need to have
a **full** `planet.mbtiles` ready in the `export` folder.

Now **merge-jobs** will merge the MBTiles files into `./export/planet.mbtiles`.
**create-extracts** will use `tilelive-copy` to cut out extracts for countries and cities.
To produce the extracts for all cities and countries this can take up to several days.
The results will be first be stored in the `export` folder and then uploaded
to a S3 if configured.

```
docker-compose run create-extracts
```

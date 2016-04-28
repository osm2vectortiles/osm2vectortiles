# changed-tiles

The **changed-tiles** component is responsible for executing the changed tiles SQL logic
and store the list of changed tiles in a text file using [pgclimb](https://github.com/lukasmartinelli/pgclimb).

The actual logic for detecting the changed tiles is in the **import-sql** component.

## Usage

### Docker

After you have imported OSM data into **postgis** you can run **changed-tiles**.
If you run it on a fresh import you will get all tiles as changed tiles.
You need to run **import-osm-diff** first to get real changed tiles.

**changed-tiles** will store the list of changed tiles in `./export/tiles.txt`.

```
docker-compose run changed-tiles
```

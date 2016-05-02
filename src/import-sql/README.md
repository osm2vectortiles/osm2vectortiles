# import-sql

The **import-sql** component is responsible to import the SQL used for the different layers. It will also generate SQL code for different classifications and code to detect changed tiles and table management commands for different layers. 

## Usage

### Docker

This needs to run after **import-external** and **import-osm**. Only after **import-sql** has been run can you start generating vector tiles.

```
docker-compose run import-sql
```


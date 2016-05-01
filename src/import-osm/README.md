# import-osm

The **import-osm** component is the [imposm3](https://github.com/omniscale/imposm3) based import container to import OSM PBF files into the **postgis** component.
It must run after the **import-external** component.

## Usage

### Download PBF File

Use [Geofabrik](http://download.geofabrik.de/index.html) and choose the extract
of your country or region. Download it and put it into the `./src/import` container.

### Import

The **import-osm** component will take the first PBF file in the `./export` folder
and will import it into **postgis**.
After that it will update the scaleranks using Natural Earth data from **import-external** to update the scaleranks and will create generalized tables based off
the imported data.
The data is imported using imposm3 diff mode and can take up to 14hrs for the entire planet file.

```
docker-compose run import-osm
```


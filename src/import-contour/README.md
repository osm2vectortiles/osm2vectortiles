# import-contour

The **import-external** component is responsible for importing vector contour lines into the PostGIS database.

## Usage

First, put contour shapefiles into *import/contour/* folder. Shapefiles must be archived to ZIP files like this:

```
import/contour/contour_N48_E8.zip
               |- contour_N48_E8
                  |- contour_N48_E8.dbf 
                  |- contour_N48_E8.prj 
                  |- contour_N48_E8.shp 
                  |- contour_N48_E8.shx 
```

Name of folder and files and ZIP archive must be same. 

To import these files run
```
docker-compose run import-contour
```

`import-contour` should be used before `import-sql`.  

Note that `import-contour` must be called even if you are not using contour files. When there is no ZIP files in `import/contour` folder, the script creates empty tables in order to avoid errors when exporting tiles. 

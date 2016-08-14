/* OSM Landuse Polygons */

DROP TABLE IF EXISTS osm_landuse_polygon_subdivided_gen0 CASCADE;
DROP TABLE IF EXISTS osm_landuse_polygon_subdivided_gen1 CASCADE;
DROP TABLE IF EXISTS osm_landuse_polygon_subdivided CASCADE;

CREATE TABLE osm_landuse_polygon_subdivided_gen0 AS SELECT id,timestamp,type,area,st_subdivide(geometry,1024) AS geometry FROM osm_landuse_polygon_gen0;
CREATE TABLE osm_landuse_polygon_subdivided_gen1 AS SELECT id,timestamp,type,area,st_subdivide(geometry,1024) AS geometry FROM osm_landuse_polygon_gen1;
CREATE TABLE osm_landuse_polygon_subdivided AS SELECT id,timestamp,type,area,st_subdivide(geometry,1024) AS geometry FROM osm_landuse_polygon;

SELECT UpdateGeometrySRID('osm_landuse_polygon_subdivided_gen0','geometry',3857);
SELECT UpdateGeometrySRID('osm_landuse_polygon_subdivided_gen1','geometry',3857);
SELECT UpdateGeometrySRID('osm_landuse_polygon_subdivided','geometry',3857);

CREATE INDEX ON osm_landuse_polygon_subdivided_gen0 USING btree(id);
CREATE INDEX ON osm_landuse_polygon_subdivided_gen1 USING btree(id);
CREATE INDEX ON osm_landuse_polygon_subdivided USING btree(id);

CREATE INDEX ON osm_landuse_polygon_subdivided_gen0 USING btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));
CREATE INDEX ON osm_landuse_polygon_subdivided_gen1 USING btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));
CREATE INDEX ON osm_landuse_polygon_subdivided USING btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));

CREATE INDEX ON osm_landuse_polygon_subdivided_gen0 USING gist (geometry);
CREATE INDEX ON osm_landuse_polygon_subdivided_gen1 USING gist (geometry);
CREATE INDEX ON osm_landuse_polygon_subdivided USING gist (geometry);

ANALYZE osm_landuse_polygon_subdivided_gen0;
ANALYZE osm_landuse_polygon_subdivided_gen1;
ANALYZE osm_landuse_polygon_subdivided;

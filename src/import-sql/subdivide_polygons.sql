
/*
Polygons
*/

ALTER TABLE osm_landuse_polygon RENAME TO osm_landuse_polygon_full;
ALTER TABLE osm_landuse_polygon_gen1 RENAME TO osm_landuse_polygon_gen1_full;
ALTER TABLE osm_landuse_polygon_gen0 RENAME TO osm_landuse_polygon_gen0_full;

CREATE TABLE osm_landuse_polygon_gen0 AS SELECT id,timestamp,type,st_subdivide(geometry,1024) AS geometry FROM osm_landuse_polygon_gen0_full;
CREATE TABLE osm_landuse_polygon_gen1 AS SELECT id,timestamp,type,st_subdivide(geometry,1024) AS geometry FROM osm_landuse_polygon_gen1_full;
CREATE TABLE osm_landuse_polygon AS SELECT id,timestamp,type,st_subdivide(geometry,1024) AS geometry FROM osm_landuse_polygon_full;

CREATE INDEX ON osm_landuse_polygon USING btree(id);
CREATE INDEX ON osm_landuse_polygon_gen0 USING btree(id);
CREATE INDEX ON osm_landuse_polygon_gen1 USING btree(id);

CREATE INDEX ON osm_landuse_polygon USING  btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));
CREATE INDEX ON osm_landuse_polygon_gen1 USING  btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));
CREATE INDEX ON osm_landuse_polygon_gen0 USING  btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));

CREATE INDEX ON osm_landuse_polygon_gen0 USING gist(geometry);
CREATE INDEX ON osm_landuse_polygon_gen1 USING gist(geometry);
CREATE INDEX ON osm_landuse_polygon USING gist(geometry);

ANALYZE osm_landuse_polygon;
ANALYZE osm_landuse_polygon_gen0;
ANALYZE osm_landuse_polygon_gen1;


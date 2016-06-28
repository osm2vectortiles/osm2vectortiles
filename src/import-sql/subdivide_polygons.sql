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

/* OSM Ocean Polygons */

DROP TABLE IF EXISTS osm_ocean_polygon_subdivided CASCADE;
DROP TABLE IF EXISTS osm_ocean_polygon_subdivided_gen0 CASCADE;

CREATE TABLE osm_ocean_polygon_subdivided AS SELECT gid,fid,st_subdivide(geometry,1024) AS geometry FROM osm_ocean_polygon;
CREATE TABLE osm_ocean_polygon_subdivided_gen0 AS SELECT gid,fid,st_subdivide(geometry,1024) AS geometry FROM osm_ocean_polygon_gen0;

SELECT UpdateGeometrySRID('osm_ocean_polygon_subdivided_gen0','geometry',3857);
SELECT UpdateGeometrySRID('osm_ocean_polygon_subdivided','geometry',3857);

CREATE INDEX ON osm_ocean_polygon_subdivided USING btree (gid);
CREATE INDEX ON osm_ocean_polygon_subdivided_gen0 USING btree (gid);

CREATE INDEX ON osm_ocean_polygon_subdivided USING gist (geometry);
CREATE INDEX ON osm_ocean_polygon_subdivided_gen0 USING gist (geometry);

ANALYZE osm_ocean_polygon_subdivided;
ANALYZE osm_ocean_polygon_subdivided_gen0;

/* Natural-Earth Ocean Polygons */

DROP TABLE IF EXISTS ne_110m_ocean_subdivided CASCADE;
DROP TABLE IF EXISTS ne_50m_ocean_subdivided CASCADE;
DROP TABLE IF EXISTS ne_10m_ocean_subdivided CASCADE;

CREATE TABLE ne_110m_ocean_subdivided AS SELECT ogc_fid,st_subdivide(geom,1024) AS geom,scalerank,featurecla FROM ne_110m_ocean;
CREATE TABLE ne_50m_ocean_subdivided AS SELECT ogc_fid,st_subdivide(geom,1024) AS geom,scalerank,featurecla FROM ne_50m_ocean;
CREATE TABLE ne_10m_ocean_subdivided AS SELECT ogc_fid,st_subdivide(geom,1024) AS geom,featurecla,scalerank FROM ne_10m_ocean;

SELECT UpdateGeometrySRID('ne_110m_ocean_subdivided','geom',3857);
SELECT UpdateGeometrySRID('ne_50m_ocean_subdivided','geom',3857);
SELECT UpdateGeometrySRID('ne_10m_ocean_subdivided','geom',3857);

CREATE INDEX ON ne_110m_ocean_subdivided USING btree (ogc_fid);
CREATE INDEX ON ne_50m_ocean_subdivided USING btree (ogc_fid);
CREATE INDEX ON ne_10m_ocean_subdivided USING btree (ogc_fid);

CREATE INDEX ON ne_110m_ocean_subdivided USING gist (geom);
CREATE INDEX ON ne_50m_ocean_subdivided USING gist (geom);
CREATE INDEX ON ne_10m_ocean_subdivided USING gist (geom);

ANALYZE ne_110m_ocean_subdivided;
ANALYZE ne_50m_ocean_subdivided;
ANALYZE ne_10m_ocean_subdivided;

/* Update SRID for lakes and water polygons */

SELECT UpdateGeometrySRID('ne_110m_lakes','geom',3857);
SELECT UpdateGeometrySRID('ne_50m_lakes','geom',3857);
SELECT UpdateGeometrySRID('ne_10m_lakes','geom',3857);

SELECT UpdateGeometrySRID('osm_water_polygon','geometry',3857);
SELECT UpdateGeometrySRID('osm_water_polygon_gen1','geometry',3857);


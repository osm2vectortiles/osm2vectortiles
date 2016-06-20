/* OSM Landuse Polygons */

ALTER TABLE osm_landuse_polygon_gen0 RENAME TO osm_landuse_polygon_gen0_full;
ALTER TABLE osm_landuse_polygon_gen1 RENAME TO osm_landuse_polygon_gen1_full;
ALTER TABLE osm_landuse_polygon RENAME TO osm_landuse_polygon_full;

CREATE TABLE osm_landuse_polygon_gen0 AS SELECT id,timestamp,type,st_subdivide(geometry,1024) AS geometry FROM osm_landuse_polygon_gen0_full;
CREATE TABLE osm_landuse_polygon_gen1 AS SELECT id,timestamp,type,st_subdivide(geometry,1024) AS geometry FROM osm_landuse_polygon_gen1_full;
CREATE TABLE osm_landuse_polygon AS SELECT id,timestamp,type,st_subdivide(geometry,1024) AS geometry FROM osm_landuse_polygon_full;

CREATE INDEX ON osm_landuse_polygon_gen0 USING btree(id);
CREATE INDEX ON osm_landuse_polygon_gen1 USING btree(id);
CREATE INDEX ON osm_landuse_polygon USING btree(id);

CREATE INDEX ON osm_landuse_polygon_gen0 USING  btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));
CREATE INDEX ON osm_landuse_polygon_gen1 USING  btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));
CREATE INDEX ON osm_landuse_polygon USING  btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));

CREATE INDEX ON osm_landuse_polygon_gen0 USING gist(geometry);
CREATE INDEX ON osm_landuse_polygon_gen1 USING gist(geometry);
CREATE INDEX ON osm_landuse_polygon USING gist(geometry);

ANALYZE osm_landuse_polygon_gen0;
ANALYZE osm_landuse_polygon_gen1;
ANALYZE osm_landuse_polygon;

/* OSM Ocean Polygons */

ALTER TABLE osm_ocean_polygon RENAME TO osm_ocean_polygon_full;
ALTER TABLE osm_ocean_polygon_gen0 RENAME TO osm_ocean_polygon_gen0_full;

CREATE TABLE osm_ocean_polygon AS SELECT gid,fid,st_subdivide(geometry,1024) AS geometry FROM osm_ocean_polygon_full;
CREATE TABLE osm_ocean_polygon_gen0 AS SELECT gid,fid,st_subdivide(geometry,1024) AS geometry FROM osm_ocean_polygon_gen0_full;

CREATE INDEX ON osm_ocean_polygon USING btree(gid);
CREATE INDEX ON osm_ocean_polygon_gen0 USING btree(gid);

CREATE INDEX ON osm_ocean_polygon USING gist(geometry);
CREATE INDEX ON osm_ocean_polygon_gen0 USING gist(geometry);

ANALYZE osm_ocean_polygon;
ANALYZE osm_ocean_polygon_gen0;

/* Natural-Earth Ocean Polygons */

ALTER TABLE ne_110m_ocean RENAME TO ne_110m_ocean_full;
ALTER TABLE ne_50m_ocean RENAME TO ne_50m_ocean_full;
ALTER TABLE ne_10m_ocean RENAME TO ne_10m_ocean_full;

CREATE TABLE ne_110m_ocean AS SELECT ogc_fid,st_subdivide(geom,1024) AS geom,scalerank,featurecla FROM ne_110m_ocean_full;
CREATE TABLE ne_50m_ocean AS SELECT ogc_fid,st_subdivide(geom,1024) AS geom,scalerank,featurecla FROM ne_50m_ocean_full;
CREATE TABLE ne_10m_ocean AS SELECT ogc_fid,st_subdivide(geom,1024) AS geom,featurecla,scalerank FROM ne_10m_ocean_full;

CREATE INDEX ON ne_110m_ocean USING btree(ogc_fid);
CREATE INDEX ON ne_50m_ocean USING btree(ogc_fid);
CREATE INDEX ON ne_10m_ocean USING btree(ogc_fid);

CREATE INDEX ON ne_110m_ocean USING gist(geom);
CREATE INDEX ON ne_50m_ocean USING gist(geom);
CREATE INDEX ON ne_10m_ocean USING gist(geom);

ANALYZE ne_110m_ocean;
ANALYZE ne_50m_ocean;
ANALYZE ne_10m_ocean;


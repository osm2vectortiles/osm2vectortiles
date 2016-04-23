DROP TABLE IF EXISTS osm_road_clustered_z5 CASCADE;
CREATE TABLE osm_road_clustered_z5 AS
SELECT ST_CollectionExtract(unnest(ST_ClusterWithin(geometry, 50000)), 2) AS geometry, type
FROM osm_road_geometry
WHERE ST_Geometrytype(geometry) = 'ST_LineString' AND type IN ('motorway', 'trunk')
GROUP BY type;

CREATE INDEX ON osm_road_clustered_z5 USING gist (geometry);
CREATE INDEX ON osm_road_clustered_z5
USING btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));

DROP TABLE IF EXISTS osm_road_clustered_z6toz7 CASCADE;
CREATE TABLE osm_road_clustered_z6toz7 AS
SELECT ST_CollectionExtract(unnest(ST_ClusterWithin(geometry, 50000)), 2) AS geometry, type
FROM osm_road_geometry
WHERE ST_Geometrytype(geometry) = 'ST_LineString' AND type IN ('motorway', 'trunk', 'primary')
GROUP BY type;

CREATE INDEX ON osm_road_clustered_z6toz7 USING gist (geometry);
CREATE INDEX ON osm_road_clustered_z6toz7
USING btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));


DROP TABLE IF EXISTS osm_road_clustered_z8toz9 CASCADE;
CREATE TABLE osm_road_clustered_z8toz9 AS
SELECT ST_CollectionExtract(unnest(ST_ClusterWithin(geometry, 50000)), 2) AS geometry, type
FROM osm_road_geometry
WHERE ST_Geometrytype(geometry) = 'ST_LineString' AND type IN ('motorway', 'motorway_link', 'trunk', 'primary', 'secondary', 'rail', 'light_rail', 'subway')
GROUP BY type;

CREATE INDEX ON osm_road_clustered_z8toz9 USING gist (geometry);
CREATE INDEX ON osm_road_clustered_z8toz9
USING btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));

DROP TABLE IF EXISTS osm_road_clustered_z10 CASCADE;
CREATE TABLE osm_road_clustered_z10 AS
SELECT ST_CollectionExtract(unnest(ST_ClusterWithin(geometry, 50000)), 2) AS geometry, type
FROM osm_road_geometry
WHERE ST_Geometrytype(geometry) = 'ST_LineString' AND type IN ('motorway', 'motorway_link', 'trunk', 'primary', 'secondary', 'tertiary', 'rail', 'light_rail', 'subway')
GROUP BY type;

CREATE INDEX ON osm_road_clustered_z10 USING gist (geometry);
CREATE INDEX ON osm_road_clustered_z10
USING btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));

DROP TABLE IF EXISTS osm_landuse_clustered CASCADE;
CREATE TABLE osm_landuse_clustered AS
SELECT ST_CollectionExtract(unnest(ST_ClusterWithin(geometry, 5000)),3) AS geometry                    
FROM osm_landuse_polygon_gen0                                                                         
WHERE type IN ('wood');

CREATE INDEX ON osm_landuse_clustered USING gist (geometry);
CREATE INDEX ON osm_landuse_clustered
USING btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));

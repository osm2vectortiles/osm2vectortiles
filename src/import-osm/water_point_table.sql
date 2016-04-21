DROP TABLE IF EXISTS osm_water_point CASCADE;
CREATE TABLE osm_water_point AS
SELECT osm_id,
       topoint(geometry) AS geometry,
       timestamp,
       name, name_fr, name_en, name_de,
       name_es, name_ru, name_zh,
       area
FROM osm_water_polygon;

CREATE INDEX ON osm_water_point USING gist (geometry);
CREATE INDEX ON osm_water_point
USING btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));

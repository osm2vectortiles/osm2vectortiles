CREATE OR REPLACE VIEW water_z6toz12 AS
    SELECT *
    FROM osm_water_polygons_gen1;

CREATE OR REPLACE VIEW water_z13toz14 AS
    SELECT *
    FROM osm_water_polygons;

CREATE OR REPLACE VIEW layer_water AS (
    SELECT osm_id, timestamp, geometry FROM water_z6toz12
    UNION
    SELECT osm_id, timestamp, geometry FROM water_z13toz14
);

CREATE OR REPLACE VIEW water_z5toz12 AS
    SELECT *
    FROM osm_water_polygon_gen1;

CREATE OR REPLACE VIEW water_z13toz14 AS
    SELECT *
    FROM osm_water_polygon;

CREATE OR REPLACE VIEW water_layer AS (
    SELECT osm_id, timestamp, geometry FROM water_z5toz12
    UNION
    SELECT osm_id, timestamp, geometry FROM water_z13toz14
);

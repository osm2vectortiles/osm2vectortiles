CREATE OR REPLACE VIEW water_label_z10 AS
    SELECT *
    FROM osm_water_polygons
    WHERE area >= 100000000;

CREATE OR REPLACE VIEW water_label_z11 AS
    SELECT *
    FROM osm_water_polygons
    WHERE area >= 40000000;

CREATE OR REPLACE VIEW water_label_z12 AS
    SELECT *
    FROM osm_water_polygons
    WHERE area >= 20000000;

CREATE OR REPLACE VIEW water_label_z13 AS
    SELECT *
    FROM osm_water_polygons
    WHERE area >= 10000000;

CREATE OR REPLACE VIEW water_label_z14 AS
    SELECT *
    FROM osm_water_polygons;

CREATE OR REPLACE VIEW layer_water_label AS (
    SELECT osm_id, timestamp, geometry FROM water_label_z10
    UNION
    SELECT osm_id, timestamp, geometry FROM water_label_z11
    UNION
    SELECT osm_id, timestamp, geometry FROM water_label_z12
    UNION
    SELECT osm_id, timestamp, geometry FROM water_label_z13
    UNION
    SELECT osm_id, timestamp, geometry FROM water_label_z14
);

CREATE OR REPLACE VIEW building_z13 AS
    SELECT *
    FROM osm_buildings_gen0;

CREATE OR REPLACE VIEW building_z14 AS
    SELECT *
    FROM osm_buildings;

CREATE OR REPLACE VIEW layer_building AS (
    SELECT osm_id, timestamp, geometry FROM building_z13
    UNION
    SELECT osm_id, timestamp, geometry FROM building_z14
);

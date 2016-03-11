CREATE OR REPLACE VIEW aeroway_z12toz14 AS
    SELECT *
    FROM osm_aero_lines
    UNION ALL
    SELECT *
    FROM osm_aero_polygons;

CREATE OR REPLACE VIEW layer_aeroway AS (
    SELECT osm_id, timestamp, geometry FROM aeroway_z12toz14
);

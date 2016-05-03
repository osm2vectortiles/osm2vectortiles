CREATE OR REPLACE VIEW barrier_line_z14 AS
    SELECT id AS osm_id, type, geometry
    FROM osm_barrier_linestring
    UNION ALL
    SELECT id AS osm_id, type, geometry
    FROM osm_barrier_polygon;

CREATE OR REPLACE VIEW barrier_line_layer AS (
    SELECT osm_id FROM barrier_line_z14
);

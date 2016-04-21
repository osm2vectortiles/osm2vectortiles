CREATE OR REPLACE VIEW barrier_line_z14 AS
    SELECT *
    FROM osm_barrier_linestring
    UNION ALL
    SELECT *
    FROM osm_barrier_polygon;

CREATE OR REPLACE VIEW barrier_line_layer AS (
    SELECT osm_id, timestamp, geometry FROM barrier_line_z14
);

CREATE OR REPLACE VIEW barrier_line_z14 AS
    SELECT *
    FROM osm_barrier_lines
    UNION ALL
    SELECT *
    FROM osm_barrier_polygons;

CREATE OR REPLACE VIEW layer_barrier_line AS (
    SELECT osm_id, timestamp, geometry FROM barrier_line_z14
);

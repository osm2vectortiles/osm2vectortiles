CREATE OR REPLACE VIEW barrier_line_z14 AS
    SELECT *
    FROM osm_barrier_linestring
    UNION ALL
    SELECT *
    FROM osm_barrier_polygon;

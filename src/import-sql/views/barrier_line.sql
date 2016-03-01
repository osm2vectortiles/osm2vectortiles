CREATE OR REPLACE VIEW barrier_line_z14 AS
    SELECT osm_id, geometry, type
    FROM osm_barrier_lines
    UNION ALL
    SELECT osm_id, geometry, type
    FROM osm_barrier_polygons;

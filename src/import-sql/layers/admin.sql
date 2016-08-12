CREATE OR REPLACE VIEW admin_z0 AS
    SELECT 0 AS osm_id, geom AS geometry, 2 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_110m_admin_0_boundary_lines_land;

CREATE OR REPLACE VIEW admin_z1toz2 AS
    SELECT 0 AS osm_id, geom AS geometry, 2 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_50m_admin_0_boundary_lines_land
    UNION ALL
    SELECT 0 AS osm_id, geom AS geometry, 4 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_50m_admin_1_states_provinces_lines
    WHERE scalerank = 2;

CREATE OR REPLACE VIEW admin_z3 AS
    SELECT 0 AS osm_id, geom AS geometry, 2 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_50m_admin_0_boundary_lines_land
    UNION ALL
    SELECT id AS osm_id, geometry, admin_level, 0 AS disputed, maritime
    FROM osm_admin_linestring
    WHERE maritime = 1 AND admin_level = 2
    UNION ALL
    SELECT 0 AS osm_id, geom AS geometry, 4 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_10m_admin_1_states_provinces_lines_shp
    WHERE scalerank = 2;

CREATE OR REPLACE VIEW admin_z4toz5 AS
    SELECT 0 AS osm_id, geom AS geometry, 2 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_10m_admin_0_boundary_lines_land
    UNION ALL
    SELECT id AS osm_id, geometry, admin_level, 0 AS disputed, maritime
    FROM osm_admin_linestring
    WHERE maritime = 1 AND admin_level = 2
    UNION ALL
    SELECT 0 AS osm_id, geom AS geometry, 4 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_10m_admin_1_states_provinces_lines_shp
    WHERE scalerank BETWEEN 2 AND 6;

CREATE OR REPLACE VIEW admin_z6 AS
    SELECT 0 AS osm_id, geom AS geometry, 2 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_10m_admin_0_boundary_lines_land
    UNION ALL
    SELECT id AS osm_id, geometry, admin_level, 0 AS disputed, maritime
    FROM osm_admin_linestring
    WHERE maritime = 1 AND admin_level = 2
    UNION ALL
    SELECT 0 AS osm_id, geom AS geometry, 4 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_10m_admin_1_states_provinces_lines_shp
    WHERE scalerank BETWEEN 2 AND 9;

CREATE OR REPLACE VIEW admin_z7toz14 AS
    SELECT id AS osm_id, geometry, admin_level, 0 AS disputed, maritime
    FROM osm_admin_linestring
    WHERE admin_level = 2 OR admin_level = 4
    UNION ALL
    SELECT 0 AS osm_id, geom AS geometry, 2 AS admin_level, 1 AS disputed, 0 AS maritime
    FROM ne_10m_admin_0_boundary_lines_disputed_areas;

CREATE OR REPLACE VIEW admin_layer AS (
    SELECT osm_id FROM admin_z0
    UNION
    SELECT osm_id FROM admin_z1toz2
    UNION
    SELECT osm_id FROM admin_z3
    UNION
    SELECT osm_id FROM admin_z4toz5
    UNION
    SELECT osm_id FROM admin_z7toz14
);

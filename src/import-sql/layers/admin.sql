DROP VIEW IF EXISTS admin_z0 CASCADE;
CREATE VIEW admin_z0 AS
    SELECT 0 AS osm_id, ST_Simplify(geom, 78206) AS geometry, 2 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_110m_admin_0_boundary_lines_land;

DROP VIEW IF EXISTS admin_z1toz2 CASCADE;
CREATE VIEW admin_z1toz2 AS
    SELECT 0 AS osm_id, ST_Simplify(geom, 30000) AS geometry, 2 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_50m_admin_0_boundary_lines_land
    UNION ALL
    SELECT 0 AS osm_id, ST_Simplify(geom, 30000) AS geometry, 4 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_50m_admin_1_states_provinces_lines
    WHERE scalerank = 2;

DROP VIEW IF EXISTS admin_z3 CASCADE;
CREATE VIEW admin_z3 AS
    SELECT 0 AS osm_id, ST_Simplify(geom, 4888) AS geometry, 2 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_50m_admin_0_boundary_lines_land
    UNION ALL
    SELECT id AS osm_id, ST_Simplify(geometry, 4888) as geometry, admin_level, 0 AS disputed, maritime
    FROM osm_admin_linestring
    WHERE maritime = 1 AND admin_level = 2
    UNION ALL
    SELECT 0 AS osm_id, ST_Simplify(geom, 4888) AS geometry, 4 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_10m_admin_1_states_provinces_lines_shp
    WHERE scalerank = 2;

DROP VIEW IF EXISTS admin_z4toz5 CASCADE;
CREATE VIEW admin_z4toz5 AS
    SELECT 0 AS osm_id, ST_Simplify(geom, 3000) AS geometry, 2 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_10m_admin_0_boundary_lines_land
    UNION ALL
    SELECT id AS osm_id, ST_Simplify(geometry, 3000) as geometry, admin_level, 0 AS disputed, maritime
    FROM osm_admin_linestring
    WHERE maritime = 1 AND admin_level = 2
    UNION ALL
    SELECT 0 AS osm_id, ST_Simplify(geom, 3000) AS geometry, 4 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_10m_admin_1_states_provinces_lines_shp
    WHERE scalerank BETWEEN 2 AND 6;

DROP VIEW IF EXISTS admin_z6 CASCADE;
CREATE VIEW admin_z6 AS
    SELECT 0 AS osm_id, ST_Simplify(geom, 1222) AS geometry, 2 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_10m_admin_0_boundary_lines_land
    UNION ALL
    SELECT id AS osm_id, ST_Simplify(geometry, 1222) as geometry, admin_level, 0 AS disputed, maritime
    FROM osm_admin_linestring
    WHERE maritime = 1 AND admin_level = 2
    UNION ALL
    SELECT 0 AS osm_id, ST_Simplify(geom, 1222) AS geometry, 4 AS admin_level, 0 AS disputed, 0 AS maritime
    FROM ne_10m_admin_1_states_provinces_lines_shp
    WHERE scalerank BETWEEN 2 AND 9;

DROP VIEW IF EXISTS admin_z7toz14 CASCADE;
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

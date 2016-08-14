CREATE OR REPLACE VIEW water_z0 AS
    SELECT 0 AS osm_id, geometry
    FROM osm_ocean_polygon_gen0
    UNION ALL
    SELECT 0 AS osm_id, geom AS geometry
    FROM ne_110m_lakes;

CREATE OR REPLACE VIEW water_z1 AS
    SELECT 0 AS osm_id, geometry
    FROM osm_ocean_polygon_gen0
    UNION ALL
    SELECT 0 AS osm_id, geom AS geometry
    FROM ne_110m_lakes;

CREATE OR REPLACE VIEW water_z2toz3 AS
    SELECT 0 AS osm_id, geometry
    FROM osm_ocean_polygon_gen1
    UNION ALL
    SELECT 0 AS osm_id, geom AS geometry
    FROM ne_50m_lakes;

CREATE OR REPLACE VIEW water_z4 AS
    SELECT 0 AS osm_id, geometry
    FROM osm_ocean_polygon_gen1
    UNION ALL
    SELECT 0 AS osm_id, geom AS geometry
    FROM ne_10m_lakes;

CREATE OR REPLACE VIEW water_z5toz7 AS
    SELECT 0 AS osm_id, geometry
    FROM osm_ocean_polygon_gen1
    UNION ALL
    SELECT id AS osm_id, geometry
    FROM osm_water_polygon_gen0;

CREATE OR REPLACE VIEW water_z8toz10 AS
    SELECT 0 AS osm_id, geometry
    FROM osm_ocean_polygon
    UNION ALL
    SELECT id AS osm_id, geometry
    FROM osm_water_polygon_gen0;

CREATE OR REPLACE VIEW water_z11toz12 AS
    SELECT 0 AS osm_id, geometry, 0 AS area
    FROM osm_ocean_polygon
    UNION ALL
    SELECT id AS osm_id, geometry, area
    FROM osm_water_polygon
    WHERE area >= 15000;

CREATE OR REPLACE VIEW water_z13toz14 AS
    SELECT 0 AS osm_id, geometry
    FROM osm_ocean_polygon
    UNION ALL
    SELECT id AS osm_id, geometry
    FROM osm_water_polygon;

CREATE OR REPLACE VIEW water_layer AS (
    SELECT osm_id FROM water_z0
    UNION
    SELECT osm_id FROM water_z1
    UNION
    SELECT osm_id FROM water_z2toz3
    UNION
    SELECT osm_id FROM water_z4
    UNION
    SELECT osm_id FROM water_z5toz7
    UNION
    SELECT osm_id FROM water_z8toz10
    UNION
    SELECT osm_id FROM water_z11toz12
    UNION
    SELECT osm_id FROM water_z13toz14
);

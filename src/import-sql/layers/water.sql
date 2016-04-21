CREATE OR REPLACE VIEW water_z0 AS
    SELECT 0 AS osm_id, geom AS geometry
    FROM ne_110m_ocean
    UNION ALL
    SELECT 0 AS osm_id, geom AS geometry
    FROM ne_110m_lakes;

CREATE OR REPLACE VIEW water_z1 AS
    SELECT 0 AS osm_id, geom AS geometry
    FROM ne_50m_ocean
    UNION ALL
    SELECT 0 AS osm_id, geom AS geometry
    FROM ne_110m_lakes;

CREATE OR REPLACE VIEW water_z2toz3 AS
    SELECT 0 AS osm_id, geom AS geometry
    FROM ne_10m_ocean
    UNION ALL
    SELECT 0 AS osm_id, geom AS geometry
    FROM ne_50m_lakes;

CREATE OR REPLACE VIEW water_z4 AS
    SELECT 0 AS osm_id, way AS geometry
    FROM osm_ocean_polygons_gen0
    UNION ALL
    SELECT 0 AS osm_id, geom AS geometry
    FROM ne_10m_lakes;

CREATE OR REPLACE VIEW water_z5toz7 AS
    SELECT 0 AS osm_id, way AS geometry
    FROM osm_ocean_polygons_gen0
    UNION ALL
    SELECT osm_id, geometry
    FROM osm_water_polygon_gen1;

CREATE OR REPLACE VIEW water_z8toz12 AS
    SELECT 0 AS osm_id, way AS geometry
    FROM osm_ocean_polygons
    UNION ALL
    SELECT osm_id, geometry
    FROM osm_water_polygon_gen1;

CREATE OR REPLACE VIEW water_z13toz14 AS
    SELECT 0 AS osm_id, way AS geometry
    FROM osm_ocean_polygons
    UNION ALL
    SELECT osm_id, geometry
    FROM osm_water_polygon;

CREATE OR REPLACE VIEW water_layer AS (
    SELECT osm_id, timestamp, geometry FROM osm_water_polygon
    UNION
    SELECT osm_id, timestamp, geometry FROM osm_water_polygon_gen1
);

DROP VIEW IF EXISTS water_z0 CASCADE;
CREATE VIEW water_z0 AS
    SELECT 0 AS osm_id, ST_Simplify(geometry, 2444) as geometry
    FROM osm_ocean_polygon_gen0
    UNION ALL
    SELECT 0 AS osm_id, ST_Simplify(geom, 2444) AS geometry
    FROM ne_110m_lakes;

DROP VIEW IF EXISTS water_z1 CASCADE;
CREATE VIEW water_z1 AS
    SELECT 0 AS osm_id, ST_Simplify(geometry, 2444) as geometry
    FROM osm_ocean_polygon_gen0
    UNION ALL
    SELECT 0 AS osm_id, ST_Simplify(geom, 2444) AS geometry
    FROM ne_110m_lakes;

DROP VIEW IF EXISTS water_z2toz3 CASCADE;
CREATE VIEW water_z2toz3 AS
    SELECT 0 AS osm_id, ST_Simplify(geometry, 2444) as geometry
    FROM osm_ocean_polygon_gen1
    UNION ALL
    SELECT 0 AS osm_id, ST_Simplify(geom, 2444) AS geometry
    FROM ne_50m_lakes;

DROP VIEW IF EXISTS water_z4 CASCADE;
CREATE VIEW water_z4 AS
    SELECT 0 AS osm_id, ST_Simplify(geometry, 2444) as geometry
    FROM osm_ocean_polygon_gen1
    UNION ALL
    SELECT 0 AS osm_id, ST_Simplify(geom, 2444) AS geometry
    FROM ne_10m_lakes;

DROP VIEW IF EXISTS water_z5toz7 CASCADE;
CREATE VIEW water_z5toz7 AS
    SELECT 0 AS osm_id, ST_Simplify(geometry, 916) as geometry
    FROM osm_ocean_polygon_gen1
    UNION ALL
    SELECT id AS osm_id, ST_Simplify(geometry, 916) as geometry
    FROM osm_water_polygon_gen0;

DROP VIEW IF EXISTS water_z8toz10 CASCADE;
CREATE VIEW water_z8toz10 AS
    SELECT 0 AS osm_id, ST_Simplify(geometry, 229) as geometry
    FROM osm_ocean_polygon
    UNION ALL
    SELECT id AS osm_id, ST_Simplify(geometry, 229) as geometry
    FROM osm_water_polygon_gen0;

DROP VIEW IF EXISTS water_z11toz12 CASCADE;
CREATE VIEW water_z11toz12 AS
    SELECT 0 AS osm_id, ST_Simplify(geometry, 38) as geometry, 0 AS area
    FROM osm_ocean_polygon
    UNION ALL
    SELECT id AS osm_id, ST_Simplify(geometry, 38) as geometry, area
    FROM osm_water_polygon
    WHERE area >= 15000;

DROP VIEW IF EXISTS water_z13toz14 CASCADE;
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

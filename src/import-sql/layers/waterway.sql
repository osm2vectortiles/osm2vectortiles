DROP VIEW IF EXISTS waterway_z7toz9 CASCADE;
CREATE VIEW waterway_z7toz9 AS
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, type, ST_Simplify(geometry, 305) as geometry
    FROM osm_water_linestring
    WHERE type = 'river';

DROP VIEW IF EXISTS waterway_z10toz12 CASCADE;
CREATE VIEW waterway_z10toz12 AS
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, type, ST_Simplify(geometry, 38) as geometry
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal');

DROP VIEW IF EXISTS waterway_z13 CASCADE;
CREATE VIEW waterway_z13 AS
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, type, ST_Simplify(geometry, 9) as geometry
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal', 'stream', 'drain');

DROP VIEW IF EXISTS waterway_z14 CASCADE;
CREATE OR REPLACE VIEW waterway_z14 AS
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, type, geometry
    FROM osm_water_linestring;

CREATE OR REPLACE VIEW waterway_layer AS (
    SELECT osm_id FROM waterway_z7toz9
    UNION
    SELECT osm_id FROM waterway_z10toz12
    UNION
    SELECT osm_id FROM waterway_z13
    UNION
    SELECT osm_id FROM waterway_z14
);

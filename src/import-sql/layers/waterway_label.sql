CREATE OR REPLACE VIEW waterway_label_z13 AS
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, type, geometry
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal');

CREATE OR REPLACE VIEW waterway_label_z14 AS
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, type, geometry
    FROM osm_water_linestring;

CREATE OR REPLACE VIEW waterway_label_layer AS (
    SELECT osm_id FROM waterway_label_z13
    UNION
    SELECT osm_id FROM waterway_label_z14
);

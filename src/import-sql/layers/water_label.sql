CREATE OR REPLACE VIEW water_label_z10 AS
    SELECT id AS osm_id, geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh
    FROM osm_water_point
    WHERE area >= 100000000;

CREATE OR REPLACE VIEW water_label_z11 AS
    SELECT id AS osm_id, geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh
    FROM osm_water_point
    WHERE area >= 40000000;

CREATE OR REPLACE VIEW water_label_z12 AS
    SELECT id AS osm_id, geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh
    FROM osm_water_point
    WHERE area >= 20000000;

CREATE OR REPLACE VIEW water_label_z13 AS
    SELECT id AS osm_id, geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh
    FROM osm_water_point
    WHERE area >= 10000000;

CREATE OR REPLACE VIEW water_label_z14 AS
    SELECT id AS osm_id, geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh
    FROM osm_water_point;

CREATE OR REPLACE VIEW water_label_layer AS (
    SELECT osm_id FROM water_label_z10
    UNION
    SELECT osm_id FROM water_label_z11
    UNION
    SELECT osm_id FROM water_label_z12
    UNION
    SELECT osm_id FROM water_label_z13
    UNION
    SELECT osm_id FROM water_label_z14
);

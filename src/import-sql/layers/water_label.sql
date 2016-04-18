CREATE OR REPLACE VIEW water_label_z10 AS
    SELECT osm_id, geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh, timestamp
    FROM osm_water_polygon
    WHERE area >= 100000000;

CREATE OR REPLACE VIEW water_label_z11 AS
    SELECT osm_id, geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh, timestamp
    FROM osm_water_polygon
    WHERE area >= 40000000;

CREATE OR REPLACE VIEW water_label_z12 AS
    SELECT osm_id, geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh, timestamp
    FROM osm_water_polygon
    WHERE area >= 20000000;

CREATE OR REPLACE VIEW water_label_z13 AS
    SELECT osm_id, geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh, timestamp
    FROM osm_water_polygon
    WHERE area >= 10000000;

CREATE OR REPLACE VIEW water_label_z14 AS
    SELECT osm_id, geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh, timestamp
    FROM osm_water_polygon;

CREATE OR REPLACE VIEW place_label_z3 AS (
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, 
           type, population, is_capital, capital, admin_level, scalerank, geometry 
    FROM osm_place_point
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank BETWEEN 0 AND 2
      AND type = 'city'
);

CREATE OR REPLACE VIEW place_label_z4 AS (
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, 
           type, population, is_capital, capital, admin_level, scalerank, geometry 
    FROM osm_place_point
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank BETWEEN 0 AND 4
      AND type = 'city'
);

CREATE OR REPLACE VIEW place_label_z5 AS (
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, 
           type, population, is_capital, capital, admin_level, scalerank, geometry  
    FROM osm_place_point
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank BETWEEN 0 AND 7
      AND type = 'city'
);

CREATE OR REPLACE VIEW place_label_z6toz7 AS (
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, 
           type, population, is_capital, capital, admin_level, scalerank, geometry  
    FROM osm_place_point
    WHERE name <> ''
      AND type IN ('city', 'town')
);

CREATE OR REPLACE VIEW place_label_z8 AS (
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, 
           type, population, is_capital, capital, admin_level, scalerank, geometry
    FROM osm_place_point
    WHERE name <> ''
      AND type IN ('city', 'town')
);

CREATE OR REPLACE VIEW place_label_z9 AS (
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, 
           type, population, is_capital, capital, admin_level, scalerank, geometry
    FROM osm_place_point
    WHERE name <> ''
      AND type IN ('island', 'aboriginal_lands', 'city', 'town', 'village')
);

CREATE OR REPLACE VIEW place_label_z10 AS (
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, 
           type, population, is_capital, capital, admin_level, scalerank, geometry
    FROM osm_place_point
    WHERE name <> ''
      AND type IN ('island', 'aboriginal_lands', 'city', 'town', 'village', 'suburb')
);

CREATE OR REPLACE VIEW place_label_z11toz12 AS (
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, 
           type, population, is_capital, capital, admin_level, scalerank, geometry
    FROM osm_place_point
    WHERE name <> ''
      AND type IN ('island', 'aboriginal_lands', 'city', 'town', 'village', 'suburb')
);

CREATE OR REPLACE VIEW place_label_z13 AS (
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, 
           type, population, is_capital, capital, admin_level, scalerank, geometry
    FROM osm_place_point
    WHERE name <> ''
      AND type IN ('island', 'islet', 'aboriginal_lands', 'city', 'town', 'village', 'suburb', 'hamlet')
);

CREATE OR REPLACE VIEW place_label_z14 AS (
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, 
           type, population, is_capital, capital, admin_level, scalerank, geometry
    FROM osm_place_point
    WHERE name <> ''
);

CREATE OR REPLACE VIEW place_label_layer AS (
    SELECT osm_id FROM place_label_z4
    UNION
    SELECT osm_id FROM place_label_z5
    UNION
    SELECT osm_id FROM place_label_z6toz7
    UNION
    SELECT osm_id FROM place_label_z8
    UNION
    SELECT osm_id FROM place_label_z9
    UNION
    SELECT osm_id FROM place_label_z10
    UNION
    SELECT osm_id FROM place_label_z11toz12
    UNION
    SELECT osm_id FROM place_label_z13
    UNION
    SELECT osm_id FROM place_label_z14
);

CREATE OR REPLACE FUNCTION normalize_scalerank(scalerank INTEGER) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE
        WHEN scalerank >= 9 THEN 9
        ELSE scalerank
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

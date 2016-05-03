CREATE OR REPLACE VIEW rail_station_label_z14 AS (
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, type, geometry
    FROM osm_rail_station_point
);

CREATE OR REPLACE VIEW rail_station_label_z13 AS (
    SELECT id AS osm_id, name, name_fr, name_en, name_de, name_es, name_ru, name_zh, type, geometry
    FROM osm_rail_station_point
    WHERE rail_station_class(type) = 'rail'
);

CREATE OR REPLACE VIEW rail_station_label_layer AS (
    SELECT osm_id FROM rail_station_label_z13
    UNION ALL
    SELECT osm_id FROM rail_station_label_z14
);

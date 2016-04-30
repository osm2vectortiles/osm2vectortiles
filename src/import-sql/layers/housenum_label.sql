CREATE OR REPLACE VIEW housenum_label_z14 AS
    SELECT id as osm_id, geometry, house_num
    FROM osm_housenumber_point
    UNION ALL
    SELECT id as osm_id, geometry, house_num
    FROM osm_housenumber_polygon;

CREATE OR REPLACE VIEW housenum_label_layer AS (
    SELECT osm_id FROM housenum_label_z14
);

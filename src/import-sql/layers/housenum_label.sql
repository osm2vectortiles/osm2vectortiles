CREATE OR REPLACE VIEW housenum_label_z14 AS
    SELECT osm_id, geometry, house_num, timestamp
    FROM osm_housenumber_point
    UNION ALL
    SELECT osm_id, geometry, house_num, timestamp
    FROM osm_housenumber_polygon;

CREATE OR REPLACE VIEW housenum_label_layer AS (
    SELECT osm_id, timestamp, geometry FROM housenum_label_z14
);

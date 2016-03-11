CREATE OR REPLACE VIEW housenum_label_z14 AS
    SELECT osm_id, geometry, house_num, timestamp
    FROM osm_housenumbers_points
    UNION ALL
    SELECT osm_id, topoint(geometry) AS geometry, house_num, timestamp
    FROM osm_housenumbers_polygons;

CREATE OR REPLACE VIEW layer_housenum_label AS (
    SELECT osm_id, timestamp, geometry FROM housenum_label_z14
);

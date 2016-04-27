CREATE OR REPLACE VIEW waterway_label_z13 AS
    SELECT *
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal');

CREATE OR REPLACE VIEW waterway_label_z14 AS
    SELECT *
    FROM osm_water_linestring;

CREATE OR REPLACE VIEW waterway_label_layer AS (
    SELECT osm_id FROM waterway_label_z13
    UNION
    SELECT osm_id FROM waterway_label_z14
);

CREATE OR REPLACE VIEW waterway_label_z8toz12 AS
    SELECT *
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal');

CREATE OR REPLACE VIEW waterway_label_z13 AS
    SELECT *
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal', 'stream', 'stream_intermittent');

CREATE OR REPLACE VIEW waterway_label_z14 AS
    SELECT *
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal', 'stream', 'stream_intermittent', 'ditch', 'drain');

CREATE OR REPLACE VIEW waterway_label_layer AS (
    SELECT osm_id FROM waterway_label_z8toz12
    UNION
    SELECT osm_id FROM waterway_label_z13
    UNION
    SELECT osm_id FROM waterway_label_z14
);

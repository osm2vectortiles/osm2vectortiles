CREATE OR REPLACE VIEW waterway_label_z8toz12 AS
    SELECT *
    FROM osm_water_lines
    WHERE type IN ('river', 'canal');

CREATE OR REPLACE VIEW waterway_label_z13toz14 AS
    SELECT *
    FROM osm_water_lines
    WHERE type IN ('river', 'canal', 'stream', 'stream_intermittent');

CREATE OR REPLACE VIEW layer_waterway_label AS (
    SELECT osm_id, timestamp, geometry FROM waterway_label_z8toz12
    UNION
    SELECT osm_id, timestamp, geometry FROM waterway_label_z13toz14
);

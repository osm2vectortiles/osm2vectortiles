CREATE OR REPLACE VIEW waterway_z8toz12 AS
    SELECT *
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal');

CREATE OR REPLACE VIEW waterway_z13toz14 AS
    SELECT *
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal', 'stream', 'stream_intermittent');

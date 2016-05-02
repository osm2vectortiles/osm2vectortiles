CREATE OR REPLACE VIEW waterway_z7toz9 AS
    SELECT *
    FROM osm_water_linestring
    WHERE type = 'river';

CREATE OR REPLACE VIEW waterway_z10toz12 AS
    SELECT *
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal');

CREATE OR REPLACE VIEW waterway_z13 AS
    SELECT *
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal', 'stream', 'drain');

CREATE OR REPLACE VIEW waterway_z14 AS
    SELECT *
    FROM osm_water_linestring;

CREATE OR REPLACE VIEW waterway_layer AS (
    SELECT osm_id FROM waterway_z7toz9
    UNION
    SELECT osm_id FROM waterway_z10toz12
    UNION
    SELECT osm_id FROM waterway_z13
    UNION
    SELECT osm_id FROM waterway_z14
);

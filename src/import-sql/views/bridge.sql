CREATE OR REPLACE VIEW bridge_z12toz14 AS
    SELECT *
    FROM osm_roads
    WHERE is_bridge;

CREATE OR REPLACE VIEW layer_bridge AS (
    SELECT osm_id, timestamp, geometry FROM bridge_z12toz14
);

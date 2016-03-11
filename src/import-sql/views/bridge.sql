CREATE OR REPLACE VIEW bridge_z12toz14 AS
    SELECT *
    FROM osm_roads
    WHERE is_bridge;

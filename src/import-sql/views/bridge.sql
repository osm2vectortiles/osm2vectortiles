CREATE OR REPLACE VIEW bridge_z12to14 AS
    SELECT *
    FROM osm_roads
    WHERE is_bridge;

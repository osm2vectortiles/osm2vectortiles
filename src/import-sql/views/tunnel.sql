CREATE OR REPLACE VIEW tunnel_z12toz14 AS
    SELECT *
    FROM osm_roads
    WHERE is_tunnel;

CREATE OR REPLACE VIEW layer_tunnel AS (
    SELECT osm_id, timestamp, geometry FROM tunnel_z12toz14
);

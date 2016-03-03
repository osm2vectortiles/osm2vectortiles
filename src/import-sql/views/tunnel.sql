CREATE OR REPLACE VIEW tunnel_z12toz14 AS
    SELECT *
    FROM osm_roads
    WHERE is_tunnel;

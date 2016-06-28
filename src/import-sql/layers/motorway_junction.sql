CREATE OR REPLACE VIEW motorway_junction_z11 AS
    SELECT id AS osm_id, type, ref, name, geometry
    FROM osm_motorway_junction_point
    WHERE ref <> '' AND type <> 'trunk';

CREATE OR REPLACE VIEW motorway_junction_z12toz14 AS
    SELECT id AS osm_id, type, ref, name, geometry
    FROM osm_motorway_junction_point
    WHERE ref <> '';

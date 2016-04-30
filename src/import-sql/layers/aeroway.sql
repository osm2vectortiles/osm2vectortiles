CREATE OR REPLACE VIEW aeroway_z9 AS
    SELECT id as osm_id, timestamp, type, geometry
    FROM osm_aero_linestring
    WHERE type = 'runway'
    UNION ALL
    SELECT id as osm_id, timestamp, type, geometry
    FROM osm_aero_polygon
    WHERE type = 'runway';

CREATE OR REPLACE VIEW aeroway_z10toz14 AS
    SELECT id as osm_id, timestamp, type, geometry
    FROM osm_aero_linestring
    UNION ALL
    SELECT id as osm_id, timestamp, type, geometry
    FROM osm_aero_polygon;

CREATE OR REPLACE VIEW aeroway_layer AS (
    SELECT osm_id FROM aeroway_z9
    UNION
    SELECT osm_id FROM aeroway_z10toz14
);


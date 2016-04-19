CREATE OR REPLACE VIEW aeroway_z9 AS
    SELECT *
    FROM osm_aero_linestring
    WHERE type = 'runway'
    UNION ALL
    SELECT *
    FROM osm_aero_polygon
    WHERE type = 'runway';

CREATE OR REPLACE VIEW aeroway_z10toz14 AS
    SELECT *
    FROM osm_aero_linestring
    UNION ALL
    SELECT *
    FROM osm_aero_polygon;

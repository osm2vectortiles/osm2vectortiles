CREATE OR REPLACE VIEW aeroway_z12toz14 AS
    SELECT *
    FROM osm_aero_lines
    UNION ALL
    SELECT *
    FROM osm_aero_polygons;

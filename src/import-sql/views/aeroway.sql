CREATE OR REPLACE VIEW aeroway_z12toz14 AS
    SELECT osm_id, geometry, type
    FROM osm_aero_lines
    UNION ALL
    SELECT osm_id, geometry, type
    FROM osm_aero_polygons;

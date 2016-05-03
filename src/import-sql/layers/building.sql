CREATE OR REPLACE VIEW building_z13 AS
    SELECT id AS osm_id, underground, geometry
    FROM osm_building_polygon_gen0;

CREATE OR REPLACE VIEW building_z14 AS
    SELECT id AS osm_id, underground, geometry
    FROM osm_building_polygon;

CREATE OR REPLACE VIEW building_layer AS (
    SELECT osm_id FROM building_z13
    UNION
    SELECT osm_id FROM building_z14
);

CREATE OR REPLACE FUNCTION building_is_underground(level INTEGER) RETURNS VARCHAR
AS $$
BEGIN
    IF level >= 1 THEN
        RETURN 'true';
    ELSE
        RETURN 'false';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

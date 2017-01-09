CREATE OR REPLACE VIEW building_z13 AS
    SELECT id AS osm_id, underground, height, min_height, building_levels, geometry
    FROM osm_building_polygon_gen0;

CREATE OR REPLACE VIEW building_z14 AS
    SELECT id AS osm_id, underground, height, min_height, building_levels, geometry
    FROM osm_building_polygon;

CREATE OR REPLACE VIEW building_layer AS (
    SELECT osm_id FROM building_z13
    UNION
    SELECT osm_id FROM building_z14
);

CREATE OR REPLACE FUNCTION infer_building_height(height INTEGER, building_levels INTEGER) RETURNS VARCHAR
AS $$
BEGIN
    IF height IS NOT NULL THEN
        RETURN height;
    ELSIF building_levels IS NOT NULL THEN
        RETURN (building_levels + 1) * 3;
    ELSE
        RETURN 6;
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

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

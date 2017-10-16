CREATE OR REPLACE VIEW building_z13 AS
    SELECT id AS osm_id, underground, height, min_height, levels, min_level, geometry
    FROM osm_building_polygon_gen0;

CREATE OR REPLACE VIEW building_z14 AS
    SELECT id AS osm_id, underground, height, min_height, levels, min_level, geometry
    FROM osm_building_polygon;

CREATE OR REPLACE VIEW building_layer AS (
    SELECT osm_id FROM building_z13
    UNION
    SELECT osm_id FROM building_z14
);

CREATE OR REPLACE FUNCTION infer_height(height INTEGER, levels INTEGER) RETURNS VARCHAR
AS $$
BEGIN
    IF height IS NOT NULL THEN
        RETURN height;
    ELSIF levels IS NOT NULL THEN
        RETURN (levels + 1) * 3;
    ELSE
        RETURN 6;
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION infer_min_height(min_height INTEGER, min_level INTEGER) RETURNS VARCHAR
AS $$
BEGIN
    IF min_height IS NOT NULL THEN
        RETURN min_height;
    ELSIF min_level IS NOT NULL THEN
        RETURN min_level * 3;
    ELSE
        RETURN 0;
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

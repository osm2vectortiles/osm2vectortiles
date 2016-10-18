CREATE OR REPLACE VIEW building_z13 AS
    SELECT id AS osm_id, underground, geometry, height, levels, min_height, min_level
    FROM osm_building_polygon_gen0;

CREATE OR REPLACE VIEW building_z14 AS
    SELECT id AS osm_id, underground, geometry, height, levels, min_height, min_level
    FROM osm_building_polygon;

CREATE OR REPLACE VIEW building_layer AS (
    SELECT osm_id FROM building_z13
    UNION
    SELECT osm_id FROM building_z14
);


CREATE OR REPLACE FUNCTION default_building_height(levels INTEGER) RETURNS INTEGER
AS $$
BEGIN
    IF levels IS NULL THEN
        RETURN 1;
    ELSE
        RETURN levels;
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION default_building_base_height(min_level INTEGER) RETURNS INTEGER
AS $$
BEGIN
    IF min_level IS NULL THEN
        RETURN 0;
    ELSE
        RETURN min_level;
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

CREATE OR REPLACE FUNCTION building_height(height INTEGER, levels INTEGER) RETURNS INTEGER
AS $$
BEGIN
    IF height IS NULL THEN
        RETURN 3*default_building_height(levels);
    ELSE
        RETURN height;
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION building_base_height(min_height INTEGER, min_level INTEGER) RETURNS INTEGER
AS $$
BEGIN
    IF min_height IS NULL THEN
        RETURN 3*default_building_base_height(min_level);
    ELSE
        RETURN min_height;
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

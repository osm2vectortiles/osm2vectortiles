CREATE OR REPLACE VIEW motorway_junction_z12toz14 AS
    SELECT id AS osm_id, type, ref, name, geometry
    FROM osm_motorway_junction_point;

CREATE OR REPLACE FUNCTION junction_type(type VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN type = 'motorway_junction' THEN 'motorway'
        ELSE type
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

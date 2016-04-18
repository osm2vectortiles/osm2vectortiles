CREATE OR REPLACE VIEW building_z13 AS
    SELECT *
    FROM osm_building_polygon_gen0;

CREATE OR REPLACE VIEW building_z14 AS
    SELECT *
    FROM osm_building_polygon;

CREATE OR REPLACE FUNCTION building_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
DECLARE
    buffer_size CONSTANT integer := 2;
BEGIN
    RETURN QUERY (
        WITH geoms AS (
            SELECT osm_id, timestamp, geometry FROM osm_delete
            WHERE table_name = 'osm_building_polygon'
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_building_polygon
        )
        SELECT DISTINCT t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
        FROM geoms AS c
        INNER JOIN LATERAL overlapping_tiles(c.geometry, 14, buffer_size)
                           AS t ON c.timestamp = ts
        WHERE t.tile_z BETWEEN 13 AND 14
    );
END;
$$ LANGUAGE plpgsql;

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

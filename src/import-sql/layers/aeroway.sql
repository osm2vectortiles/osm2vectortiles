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

CREATE OR REPLACE FUNCTION aeroway_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
DECLARE
    buffer_size CONSTANT integer := 4;
BEGIN
    RETURN QUERY (
        WITH geoms AS (
            SELECT osm_id, timestamp, geometry FROM osm_delete
            WHERE table_name = 'osm_aero_linestring' OR table_name = 'osm_aero_polygon'
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_aero_polygon
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_aero_linestring
        )
        SELECT DISTINCT t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
        FROM geoms AS c
        INNER JOIN LATERAL overlapping_tiles(c.geometry, 14, buffer_size)
                           AS t ON c.timestamp = ts
    );
END;
$$ LANGUAGE plpgsql;

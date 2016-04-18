CREATE OR REPLACE VIEW barrier_line_z14 AS
    SELECT *
    FROM osm_barrier_linestring
    UNION ALL
    SELECT *
    FROM osm_barrier_polygon;

CREATE OR REPLACE FUNCTION barrier_line_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
DECLARE
    buffer_size CONSTANT integer := 4;
BEGIN
    RETURN QUERY (
        WITH geoms AS (
            SELECT osm_id, timestamp, geometry FROM osm_delete
            WHERE table_name = 'osm_barrier_polygon'
               OR table_name = 'osm_barrier_linestring'
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_barrier_polygon
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_barrier_linestring
        )
        SELECT DISTINCT t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
        FROM geoms AS c
        INNER JOIN LATERAL overlapping_tiles(c.geometry, 14, buffer_size)
                           AS t ON c.timestamp = ts
        WHERE t.tile_z = 14
    );
END;
$$ LANGUAGE plpgsql;

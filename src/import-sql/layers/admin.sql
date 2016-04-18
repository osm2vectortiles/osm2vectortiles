CREATE OR REPLACE VIEW admin_z2toz6 AS
    SELECT *
    FROM osm_admin_linestring
    WHERE maritime = 1
      AND admin_level = 2;

CREATE OR REPLACE VIEW admin_z7toz14 AS
    SELECT *
    FROM osm_admin_linestring
    WHERE ( admin_level = 2 OR admin_level = 4 );

CREATE OR REPLACE FUNCTION admin_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
DECLARE
    buffer_size CONSTANT integer := 4;
BEGIN
    RETURN QUERY (
        WITH geoms AS (
            SELECT osm_id, timestamp, geometry FROM osm_delete
            WHERE table_name = 'osm_admin_linestring'
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_admin_linestring
        )
        SELECT DISTINCT t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
        FROM geoms AS c
        INNER JOIN LATERAL overlapping_tiles(c.geometry, 14, buffer_size)
                           AS t ON c.timestamp = ts
    );
END;
$$ LANGUAGE plpgsql;

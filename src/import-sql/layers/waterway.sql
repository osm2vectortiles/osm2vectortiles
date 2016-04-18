CREATE OR REPLACE VIEW waterway_z8toz12 AS
    SELECT *
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal');

CREATE OR REPLACE VIEW waterway_z13toz14 AS
    SELECT *
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal', 'stream', 'stream_intermittent');

CREATE OR REPLACE FUNCTION waterway_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
DECLARE
    -- waterway has buffer of 4 but if we take buffer of 8 we can at the
    -- same time also cover the changed tiles of waterway_label
    buffer_size CONSTANT integer := 4;
BEGIN
    RETURN QUERY (
        WITH geoms AS (
            SELECT osm_id, timestamp, geometry FROM osm_delete
            WHERE table_name = 'osm_water_linestring'
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_water_linestring
        )
        SELECT DISTINCT t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
        FROM geoms AS c
        INNER JOIN LATERAL overlapping_tiles(c.geometry, 14, buffer_size)
                           AS t ON c.timestamp = ts
        WHERE t.tile_z BETWEEN 8 AND 14
    );
END;
$$ LANGUAGE plpgsql;

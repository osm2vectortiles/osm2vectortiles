CREATE OR REPLACE VIEW housenum_label_z14 AS
    SELECT osm_id, geometry, house_num, timestamp
    FROM osm_housenumber_point
    UNION ALL
    SELECT osm_id, geometry, house_num, timestamp
    FROM osm_housenumber_polygon;

CREATE OR REPLACE FUNCTION housenum_label_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
DECLARE
    buffer_size CONSTANT integer := 64;
BEGIN
    RETURN QUERY (
        WITH geoms AS (
            SELECT osm_id, timestamp, geometry FROM osm_delete
            WHERE table_name = 'osm_housenumber_point'
               OR table_name = 'osm_housenumber_polygon'
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_housenumber_point
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_housenumber_polygon
        )
        SELECT DISTINCT t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
        FROM geoms AS c
        INNER JOIN LATERAL overlapping_tiles(c.geometry, 14, buffer_size)
                           AS t ON c.timestamp = ts
        WHERE t.tile_z = 14
    );
END;
$$ LANGUAGE plpgsql;

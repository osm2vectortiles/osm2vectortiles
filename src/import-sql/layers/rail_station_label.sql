CREATE OR REPLACE VIEW rail_station_label_z14 AS (
    SELECT *
    FROM osm_rail_station_point
);

CREATE OR REPLACE VIEW rail_station_label_z12toz13 AS (
    SELECT *
    FROM osm_rail_station_point
    WHERE classify_rail_station(type) = 'rail'
);

CREATE OR REPLACE FUNCTION mountain_peak_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
DECLARE
    buffer_size CONSTANT integer := 64;
BEGIN
    RETURN QUERY (
        WITH geoms AS (
            SELECT osm_id, timestamp, geometry FROM osm_delete
            WHERE table_name = 'osm_rail_station_point'
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_rail_station_point
        )
        SELECT DISTINCT t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
        FROM geoms AS c
        INNER JOIN LATERAL overlapping_tiles(c.geometry, 14, buffer_size)
                           AS t ON c.timestamp = ts
        WHERE t.tile.z BETWEEN 12 AND 14
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW water_z5toz12 AS
    SELECT *
    FROM osm_water_polygon_gen1;

CREATE OR REPLACE VIEW water_z13toz14 AS
    SELECT *
    FROM osm_water_polygon;

CREATE OR REPLACE VIEW water_layer AS (
    SELECT osm_id, timestamp, geometry FROM water_z5toz12
    UNION
    SELECT osm_id, timestamp, geometry FROM water_z13toz14
);

CREATE OR REPLACE FUNCTION water_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
DECLARE
    -- water label has buffer of 8 but if we take buffer of 64 we can at the
    -- same time also cover the changed tiles of water_label
    buffer_size CONSTANT integer := 64;
BEGIN
    RETURN QUERY (
        WITH geoms AS (
            SELECT osm_id, timestamp, geometry FROM osm_delete
            WHERE table_name = 'osm_water_polygon'
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_water_polygon
        )
        SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
        FROM geoms AS c
        INNER JOIN LATERAL overlapping_tiles(c.geometry, 14, buffer_size)
                           AS t ON c.timestamp = ts
        WHERE t.tile_z BETWEEN 5 AND 14
    );
END;
$$ LANGUAGE plpgsql;

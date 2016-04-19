CREATE OR REPLACE VIEW airport_label_z9toz14 AS
    SELECT osm_id, geometry, name, name_en, name_es, name_fr, name_de, name_ru, name_zh, 
        iata, ref, icao, faa, aerodrome, type, kind, 0 AS area, timestamp
    FROM osm_airport_point
    UNION ALL
    SELECT osm_id, geometry, name, name_en, name_es, name_fr, name_de,
        name_ru, name_zh, iata, ref, icao, faa, aerodrome, type, kind, area, timestamp
    FROM osm_airport_polygon;

CREATE OR REPLACE FUNCTION airport_label_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
DECLARE
    buffer_size CONSTANT integer := 64;
BEGIN
    RETURN QUERY (
        WITH geoms AS (
            SELECT osm_id, timestamp, geometry FROM osm_delete
            WHERE table_name = 'osm_mountain_peak_point'
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_mountain_peak_point
        )
        SELECT DISTINCT t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
        FROM geoms AS c
        INNER JOIN LATERAL overlapping_tiles(c.geometry, 14, buffer_size)
                           AS t ON c.timestamp = ts
        WHERE t.tile.z BETWEEN 12 AND 14
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION airport_label_scalerank(maki VARCHAR, area REAL, aerodrome VARCHAR) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE
        WHEN (maki = 'airport' AND area >= 300000) OR aerodrome = 'international' THEN 1
        WHEN maki = 'airport' AND area < 300000 THEN 2
        WHEN maki = 'airfield' AND area >= 145000 THEN 3
        WHEN maki = 'airfield' AND area < 145000 THEN 4
        ELSE 4
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION airport_label_class(kind VARCHAR, type VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN kind = 'heliport' THEN 'heliport'
        WHEN kind = 'aerodrome' AND type IN ('public', 'Public') THEN 'airport'
        WHEN kind = 'aerodrome' AND type IN ('private', 'Private', 'military/public', 'Military/Public') THEN 'airfield'
        ELSE 'airfield'
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE VIEW airport_label_z9toz14 AS
    SELECT osm_id, geometry, name, name_en, name_es, name_fr, name_de, name_ru, name_zh, 
        iata, ref, icao, faa, aerodrome, type, kind, 0 AS area, timestamp
    FROM osm_airport_point
    UNION ALL
    SELECT osm_id, geometry, name, name_en, name_es, name_fr, name_de,
        name_ru, name_zh, iata, ref, icao, faa, aerodrome, type, kind, area, timestamp
    FROM osm_airport_polygon;

CREATE OR REPLACE VIEW airport_label_layer AS (
    SELECT osm_id, timestamp, geometry FROM airport_label_z9toz14
);

CREATE OR REPLACE FUNCTION airport_label_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM airport_label_layer AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON c.timestamp = ts
		)

		SELECT c.x, c.y, c.z FROM airport_label_z9toz14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 9 AND 14
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

CREATE OR REPLACE FUNCTION classify_airport_label(kind VARCHAR, type VARCHAR) RETURNS VARCHAR
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

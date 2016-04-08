CREATE OR REPLACE VIEW airport_label_z9toz14 AS
    SELECT osm_id, geometry, name, name_en, name_es, name_fr, name_de, name_ru, name_zh, 
        iata, ref, icao, faa, aerodrome, type, kind, 0 AS area, timestamp
    FROM osm_airport_point
    UNION ALL
    SELECT osm_id, topoint(geometry) AS geometry, name, name_en, name_es, name_fr, name_de, 
        name_ru, name_zh, iata, ref, icao, faa, aerodrome, type, kind, area, timestamp
    FROM osm_airport_polygon;

CREATE OR REPLACE VIEW layer_airport_label AS (
    SELECT osm_id, timestamp, geometry FROM airport_label_z9toz14
);

CREATE OR REPLACE FUNCTION changed_tiles_airport_label(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM layer_airport_label AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON c.timestamp = ts
		)

		SELECT c.x, c.y, c.z FROM airport_label_z9toz14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 9 AND 14
	);
END;
$$ LANGUAGE plpgsql;

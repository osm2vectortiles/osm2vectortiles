CREATE OR REPLACE VIEW mountain_peak_label_z12toz14 AS
    SELECT *
    FROM osm_mountain_peak_point;

CREATE OR REPLACE VIEW mountain_peak_label_layer AS (
    SELECT osm_id, timestamp, geometry FROM mountain_peak_label_z12toz14
);

CREATE OR REPLACE FUNCTION mountain_peak_label_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM mountain_peak_label_layer AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON c.timestamp = ts
		)

		SELECT c.x, c.y, c.z FROM mountain_peak_label_z12toz14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 12 AND 14
	);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION meter_to_feet(meter INTEGER) RETURNS INTEGER
AS $$
BEGIN
    RETURN round(meter * 3.28084);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION mountain_peak_type(type VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    IF type = 'volcano' THEN
        RETURN type;
    ELSE
        RETURN 'mountain';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE VIEW rail_station_label_z12toz14 AS
    SELECT *
    FROM osm_rail_station_point;

CREATE OR REPLACE VIEW layer_rail_station_label AS (
    SELECT osm_id, timestamp, geometry FROM rail_station_label_z12toz14
);

CREATE OR REPLACE FUNCTION changed_tiles_rail_station_label(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM layer_rail_station_label AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON c.timestamp = ts
		)

		SELECT c.x, c.y, c.z FROM rail_station_label_z12toz14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 12 AND 14
	);
END;
$$ LANGUAGE plpgsql;

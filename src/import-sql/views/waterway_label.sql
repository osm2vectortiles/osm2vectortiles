CREATE OR REPLACE VIEW waterway_label_z8toz12 AS
    SELECT *
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal');

CREATE OR REPLACE VIEW waterway_label_z13toz14 AS
    SELECT *
    FROM osm_water_linestring
    WHERE type IN ('river', 'canal', 'stream', 'stream_intermittent');

CREATE OR REPLACE VIEW layer_waterway_label AS (
    SELECT osm_id, timestamp, geometry FROM waterway_label_z8toz12
    UNION
    SELECT osm_id, timestamp, geometry FROM waterway_label_z13toz14
);

CREATE OR REPLACE FUNCTION changed_tiles_waterway_label(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH created_or_updated_osm_ids AS (
            SELECT osm_id FROM osm_create
            WHERE table_name = 'osm_water_linestring' AND timestamp = ts
            UNION
            SELECT osm_id FROM osm_modify
            WHERE table_name = 'osm_water_linestring' AND timestamp = ts
        ), changed_geometries AS (
        	SELECT osm_id, timestamp, geometry FROM osm_delete
            WHERE table_name = 'osm_water_linestring'
            UNION
		    SELECT osm_id, geometry FROM layer_waterway_label
		    WHERE timestamp = ts AND osm_id IN (SELECT osm_id FROM created_or_updated_osm_ids)
		), changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM changed_geometries AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON true
		)

		SELECT c.x, c.y, c.z FROM waterway_label_z13toz14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 13 AND 14
        UNION

		SELECT c.x, c.y, c.z FROM waterway_label_z8toz12 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 8 AND 12
	);
END;
$$ LANGUAGE plpgsql;

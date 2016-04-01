CREATE OR REPLACE VIEW water_z6toz12 AS
    SELECT *
    FROM osm_water_polygon_gen1;

CREATE OR REPLACE VIEW water_z13toz14 AS
    SELECT *
    FROM osm_water_polygon;

CREATE OR REPLACE VIEW layer_water AS (
    SELECT osm_id, timestamp, geometry FROM water_z6toz12
    UNION
    SELECT osm_id, timestamp, geometry FROM water_z13toz14
);

CREATE OR REPLACE FUNCTION changed_tiles_water(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM layer_water AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON c.timestamp = ts
		)

		SELECT c.x, c.y, c.z FROM water_z13toz14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 13 AND 14
        UNION

		SELECT c.x, c.y, c.z FROM water_z6toz12 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 6 AND 12
	);
END;
$$ LANGUAGE plpgsql;

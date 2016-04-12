CREATE OR REPLACE VIEW admin_z2toz6 AS
    SELECT *
    FROM osm_admin_linestring
    WHERE maritime = 1
      AND admin_level = 2;

CREATE OR REPLACE VIEW admin_z7toz14 AS
    SELECT *
    FROM osm_admin_linestring
    WHERE ( admin_level = 2 OR admin_level = 4 );

CREATE OR REPLACE VIEW admin_layer AS (
    SELECT osm_id, timestamp, geometry FROM admin_z2toz6
    UNION
    SELECT osm_id, timestamp, geometry FROM admin_z7toz14
);

CREATE OR REPLACE FUNCTION admin_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM admin_layer AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON c.timestamp = ts
		)

		SELECT c.x, c.y, c.z FROM admin_z7toz14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 7 AND 14
		UNION

		SELECT c.x, c.y, c.z FROM admin_z2toz6 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 2 AND 6
	);
END;
$$ LANGUAGE plpgsql;

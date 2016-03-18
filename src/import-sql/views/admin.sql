CREATE OR REPLACE VIEW admin_z2toz6 AS
    SELECT *
    FROM osm_admin_linestring
    WHERE maritime = 1
      AND admin_level = 2;

CREATE OR REPLACE VIEW admin_z7toz14 AS
    SELECT *
    FROM osm_admin_linestring
    WHERE ( admin_level = 2 OR admin_level = 4 );

CREATE OR REPLACE VIEW layer_admin AS (
    SELECT osm_id, timestamp, geometry FROM admin_z2toz6
    UNION
    SELECT osm_id, timestamp, geometry FROM admin_z7toz14
);

CREATE OR REPLACE FUNCTION changed_tiles_admin(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH created_or_updated_osm_ids AS (
	    	SELECT osm_id FROM osm_create 
	    	WHERE table_name = 'osm_admin_linestring' AND timestamp = ts
	    	UNION
	    	SELECT osm_id FROM osm_update
	    	WHERE table_name = 'osm_admin_linestring' AND timestamp = ts
		), changed_geometries AS (
			SELECT osm_id, timestamp, geometry FROM osm_delete
    		WHERE table_name = 'osm_admin_linestring'
    		UNION
		    SELECT osm_id, geometry FROM layer_admin
		    WHERE timestamp = ts AND osm_id IN (SELECT osm_id FROM created_or_updated_osm_ids)
		), changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM changed_geometries AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON true
		)

		SELECT c.x, c.y, c.z FROM admin_z7toz14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 7 AND 14
		UNION

		SELECT c.x, c.y, c.z FROM admin_z2toz6 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 2 AND 6
	);
END;
$$ LANGUAGE plpgsql;

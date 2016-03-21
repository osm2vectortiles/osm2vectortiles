CREATE OR REPLACE VIEW building_z13 AS
    SELECT *
    FROM osm_building_polygon_gen0;

CREATE OR REPLACE VIEW building_z14 AS
    SELECT *
    FROM osm_building_polygon;

CREATE OR REPLACE VIEW layer_building AS (
    SELECT osm_id, timestamp, geometry FROM building_z13
    UNION
    SELECT osm_id, timestamp, geometry FROM building_z14
);

CREATE OR REPLACE FUNCTION changed_tiles_building(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
	    WITH created_or_updated_osm_ids AS (
	    	SELECT osm_id FROM osm_create 
	        WHERE table_name = 'osm_building_polygon' AND timestamp = ts
	    	UNION
	    	SELECT osm_id FROM osm_modify
	        WHERE table_name = 'osm_building_polygon' AND timestamp = ts
		), changed_geometries AS (
			SELECT osm_id, timestamp, geometry FROM osm_delete
    	    WHERE table_name = 'osm_building_polygon'
    		UNION
		    SELECT osm_id, geometry FROM layer_building
		    WHERE timestamp = ts AND osm_id IN (SELECT osm_id FROM created_or_updated_osm_ids)
		), changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM changed_geometries AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON true
		)

		SELECT c.x, c.y, c.z FROM building_z14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 14
        UNION

		SELECT c.x, c.y, c.z FROM building_z13 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 13
	);
END;
$$ LANGUAGE plpgsql;



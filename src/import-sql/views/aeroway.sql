CREATE OR REPLACE VIEW aeroway_z12toz14 AS
    SELECT *
    FROM osm_aero_linestring
    UNION ALL
    SELECT *
    FROM osm_aero_polygon;

CREATE OR REPLACE VIEW layer_aeroway AS (
    SELECT osm_id, timestamp, geometry FROM aeroway_z12toz14
);

CREATE OR REPLACE FUNCTION changed_tiles_aeroway(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_geometries AS (
			SELECT osm_id, timestamp, geometry FROM osm_delete
    		WHERE table_name = 'osm_aero_linestring' OR table_name = 'osm_aero_polygon'
    		UNION
		    SELECT osm_id, timestamp, geometry FROM layer_aeroway 
		), changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM changed_geometries AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON c.timestamp = ts
		)

		SELECT c.x, c.y, c.z FROM aeroway_z12toz14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 12 AND 14
	);
END;
$$ LANGUAGE plpgsql;

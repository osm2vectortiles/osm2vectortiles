CREATE OR REPLACE VIEW aeroway_z9 AS
    SELECT *
    FROM osm_aero_linestring
    WHERE type = 'runway'
    UNION ALL
    SELECT *
    FROM osm_aero_polygon
    WHERE type = 'runway';

CREATE OR REPLACE VIEW aeroway_z10toz14 AS
    SELECT *
    FROM osm_aero_linestring
    UNION ALL
    SELECT *
    FROM osm_aero_polygon;

CREATE OR REPLACE VIEW layer_aeroway AS (
    SELECT osm_id, timestamp, geometry FROM aeroway_z9
    UNION
    SELECT osm_id, timestamp, geometry FROM aeroway_z10toz14
);

CREATE OR REPLACE FUNCTION changed_tiles_aeroway(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM layer_aeroway AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON c.timestamp = ts
		)

		SELECT c.x, c.y, c.z FROM aeroway_z9 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 9
		UNION

		SELECT c.x, c.y, c.z FROM aeroway_z10toz14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 12 AND 14
	);
END;
$$ LANGUAGE plpgsql;

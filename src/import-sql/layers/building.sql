CREATE OR REPLACE VIEW building_z13 AS
    SELECT *
    FROM osm_building_polygon_gen0;

CREATE OR REPLACE VIEW building_z14 AS
    SELECT *
    FROM osm_building_polygon;

CREATE OR REPLACE VIEW building_layer AS (
    SELECT osm_id, timestamp, geometry FROM building_z13
    UNION
    SELECT osm_id, timestamp, geometry FROM building_z14
);

CREATE OR REPLACE FUNCTION building_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM building_layer AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON c.timestamp = ts
		)

		SELECT c.x, c.y, c.z FROM building_z14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 14
        UNION

		SELECT c.x, c.y, c.z FROM building_z13 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 13
	);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION building_is_underground(level INTEGER) RETURNS VARCHAR
AS $$
BEGIN
    IF level >= 1 THEN
        RETURN 'true';
    ELSE
        RETURN 'false';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

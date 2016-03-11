CREATE OR REPLACE VIEW building_z13 AS
    SELECT *
    FROM osm_buildings_gen0;

CREATE OR REPLACE VIEW building_z14 AS
    SELECT *
    FROM osm_buildings;

CREATE OR REPLACE VIEW layer_building AS (
    SELECT osm_id, timestamp, geometry FROM building_z13
    UNION
    SELECT osm_id, timestamp, geometry FROM building_z14
);

CREATE OR REPLACE FUNCTION changed_tiles_building(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_geometries AS (
		    SELECT osm_id, geometry FROM layer_building
		    WHERE timestamp = ts
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



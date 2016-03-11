CREATE OR REPLACE VIEW housenum_label_z14 AS
    SELECT osm_id, geometry, house_num, timestamp
    FROM osm_housenumbers_points
    UNION ALL
    SELECT osm_id, topoint(geometry) AS geometry, house_num, timestamp
    FROM osm_housenumbers_polygons;

CREATE OR REPLACE VIEW layer_housenum_label AS (
    SELECT osm_id, timestamp, geometry FROM housenum_label_z14
);
CREATE OR REPLACE FUNCTION changed_tiles_housenum_label(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_geometries AS (
		    SELECT osm_id, geometry FROM layer_housenum_label
		    WHERE timestamp = ts
		), changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.x, t.y, t.z
		    FROM changed_geometries AS c
		    INNER JOIN LATERAL point_to_tiles(
                ST_Y(ST_Transform(c.geometry, 4324)),
                ST_X(ST_Transform(c.geometry, 4324)),
                14
            ) AS t ON true
		)

		SELECT c.x, c.y, c.z FROM housenum_label_z14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 14
	);
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE VIEW place_label_z3 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank BETWEEN 1 AND 2
      AND type = 'city'
);

CREATE OR REPLACE VIEW place_label_z4 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank BETWEEN 1 AND 4
      AND type = 'city'
);

CREATE OR REPLACE VIEW place_label_z5 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank BETWEEN 1 AND 7
      AND type = 'city'
);

CREATE OR REPLACE VIEW place_label_z6toz7 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank BETWEEN 1 AND 10
      AND type IN ('city', 'town')
);

CREATE OR REPLACE VIEW place_label_z8 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND type IN ('city', 'town')
);

CREATE OR REPLACE VIEW place_label_z9 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND type IN ('island', 'islet', 'aboriginal_lands', 'city', 'town')
);

CREATE OR REPLACE VIEW place_label_z10 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND type IN ('island', 'islet', 'aboriginal_lands', 'city', 'town', 'village')
);

CREATE OR REPLACE VIEW place_label_z11toz12 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND type IN ('island', 'islet', 'aboriginal_lands', 'city', 'town', 'village', 'suburb')
);

CREATE OR REPLACE VIEW place_label_z13 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
      AND type IN ('island', 'islet', 'aboriginal_lands', 'city', 'town', 'village', 'suburb', 'hamlet')
);

CREATE OR REPLACE VIEW place_label_z14 AS (
    SELECT * FROM osm_place_geometry
    WHERE name <> ''
);

CREATE OR REPLACE VIEW place_label_layer AS (
    SELECT osm_id, timestamp, geometry FROM place_label_z3
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z4
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z5
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z6toz7
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z8
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z9
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z10
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z11toz12
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z13
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z14
);

CREATE OR REPLACE FUNCTION place_label_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM place_label_layer AS c
            INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON c.timestamp = ts
		)

		SELECT c.x, c.y, c.z FROM place_label_z14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 14
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z13 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 13
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z11toz12 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 11 AND 12
        UNION

        SELECT c.x, c.y, c.z FROM place_label_z10 AS l
        INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 10
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z9 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 9
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z8 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 8
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z6toz7 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 6 AND 7
        UNION

        SELECT c.x, c.y, c.z FROM place_label_z5 AS l
        INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 5
        UNION

        SELECT c.x, c.y, c.z FROM place_label_z4 AS l
        INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 4
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z3 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 3
	);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION normalize_scalerank(scalerank INTEGER) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE
        WHEN scalerank >= 9 THEN 9
        ELSE scalerank
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

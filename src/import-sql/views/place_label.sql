CREATE OR REPLACE VIEW place_label_z4toz5 AS
    SELECT *
    FROM osm_place_point
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank < 3;

CREATE OR REPLACE VIEW place_label_z6 AS
    SELECT *
    FROM osm_place_point
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank < 8;

CREATE OR REPLACE VIEW place_label_z7 AS
    SELECT *
    FROM osm_place_point
    WHERE name <> ''
      AND scalerank IS NOT NULL;

CREATE OR REPLACE VIEW place_label_z8 AS
    SELECT *
    FROM osm_place_point
    WHERE name <> ''
      AND type IN ('city', 'town');

CREATE OR REPLACE VIEW place_label_z9toz10 AS
    SELECT *
    FROM osm_place_point
    WHERE name <> ''
      AND type IN ('city', 'town', 'district');

CREATE OR REPLACE VIEW place_label_z11toz12 AS
    SELECT *
    FROM osm_place_point
    WHERE name <> ''
      AND type IN ('city', 'town', 'district', 'village');

CREATE OR REPLACE VIEW place_label_z13 AS
    SELECT *
    FROM osm_place_point
    WHERE name <> ''
      AND type IN ('city', 'town', 'district', 'village', 'hamlet', 'suburb','neighbourhood');

CREATE OR REPLACE VIEW place_label_z14 AS
    SELECT *
    FROM osm_place_point
    WHERE name <> '';

CREATE OR REPLACE VIEW layer_place_label AS (
    SELECT osm_id, timestamp, geometry FROM place_label_z4toz5
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z6
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z7
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z8
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z9toz10
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z11toz12
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z13
    UNION
    SELECT osm_id, timestamp, geometry FROM place_label_z14
);

CREATE OR REPLACE FUNCTION changed_tiles_place_label(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM layer_place_label AS c
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

		SELECT c.x, c.y, c.z FROM place_label_z9toz10 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 9 AND 10
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z8 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 8
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z7 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 7
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z6 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 6
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z4toz5 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 4 AND 5
	);
END;
$$ LANGUAGE plpgsql;

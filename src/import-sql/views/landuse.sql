CREATE OR REPLACE VIEW landuse_z5 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 300000000;

CREATE OR REPLACE VIEW landuse_z6 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 100000000;

CREATE OR REPLACE VIEW landuse_z7 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 25000000;

CREATE OR REPLACE VIEW landuse_z8 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 5000000;

CREATE OR REPLACE VIEW landuse_z9 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 2000000;

CREATE OR REPLACE VIEW landuse_z10 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 500000;

CREATE OR REPLACE VIEW landuse_z11 AS
    SELECT *
    FROM osm_landuse_polygon_gen1
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 100000;

CREATE OR REPLACE VIEW landuse_z12 AS
    SELECT *
    FROM osm_landuse_polygon
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 10000;

CREATE OR REPLACE VIEW landuse_z13toz14 AS
    SELECT *
    FROM osm_landuse_polygon
    WHERE type NOT IN ('wetland', 'marsh', 'swamp', 'bog', 'mud', 'tidalflat');

CREATE OR REPLACE VIEW layer_landuse AS (
    SELECT osm_id, timestamp, geometry FROM landuse_z5
    UNION
    SELECT osm_id, timestamp, geometry FROM landuse_z6
    UNION
    SELECT osm_id, timestamp, geometry FROM landuse_z7
    UNION
    SELECT osm_id, timestamp, geometry FROM landuse_z8
    UNION
    SELECT osm_id, timestamp, geometry FROM landuse_z9
    UNION
    SELECT osm_id, timestamp, geometry FROM landuse_z10
    UNION
    SELECT osm_id, timestamp, geometry FROM landuse_z11
    UNION
    SELECT osm_id, timestamp, geometry FROM landuse_z12
    UNION
    SELECT osm_id, timestamp, geometry FROM landuse_z13toz14
);

CREATE OR REPLACE FUNCTION changed_tiles_landuse(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH created_or_updated_osm_ids AS (
            SELECT osm_id FROM osm_create 
            WHERE table_name = 'osm_landuse_polygon' AND timestamp = ts
            UNION
            SELECT osm_id FROM osm_update
            WHERE table_name = 'osm_landuse_polygon' AND timestamp = ts
        ), changed_geometries AS (
            SELECT osm_id, timestamp, geometry FROM osm_delete
            WHERE table_name = 'osm_landuse_polygon'
            UNION
		    SELECT osm_id, geometry FROM layer_landuse
		    WHERE timestamp = ts AND osm_id IN (SELECT osm_id FROM created_or_updated_osm_ids)
		), changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM changed_geometries AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON true
		)

		SELECT c.x, c.y, c.z FROM landuse_z13toz14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 13 AND 14
		UNION

		SELECT c.x, c.y, c.z FROM landuse_z12 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 12
		UNION

		SELECT c.x, c.y, c.z FROM landuse_z11 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 11
		UNION

		SELECT c.x, c.y, c.z FROM landuse_z10 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 10
		UNION

		SELECT c.x, c.y, c.z FROM landuse_z9 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 9
		UNION

		SELECT c.x, c.y, c.z FROM landuse_z8 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 8
		UNION

		SELECT c.x, c.y, c.z FROM landuse_z7 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 7
		UNION

		SELECT c.x, c.y, c.z FROM landuse_z6 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 6
		UNION
		SELECT c.x, c.y, c.z FROM landuse_z5 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 5
	);
END;
$$ LANGUAGE plpgsql;


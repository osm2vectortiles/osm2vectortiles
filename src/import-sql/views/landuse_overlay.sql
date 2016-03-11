CREATE OR REPLACE VIEW landuse_overlay_z7 AS
    SELECT *
    FROM osm_landusages_gen0
    WHERE type IN ('wetland', 'marsh', 'swamp', 'bog', 'mud', 'tidalflat')
      AND st_area(geometry) > 20000000;

CREATE OR REPLACE VIEW landuse_overlay_z8 AS
    SELECT *
    FROM osm_landusages_gen0
    WHERE type IN ('wetland', 'marsh', 'swamp', 'bog', 'mud', 'tidalflat')
      AND st_area(geometry) > 6000000;

CREATE OR REPLACE VIEW landuse_overlay_z9 AS
    SELECT *
    FROM osm_landusages_gen0
    WHERE type IN ('wetland', 'marsh', 'swamp', 'bog', 'mud', 'tidalflat')
      AND st_area(geometry) > 2000000;

CREATE OR REPLACE VIEW landuse_overlay_z10 AS
    SELECT *
    FROM osm_landusages_gen0
    WHERE type IN ('wetland', 'marsh', 'swamp', 'bog', 'mud', 'tidalflat')
      AND st_area(geometry) > 500000;

CREATE OR REPLACE VIEW landuse_overlay_z11toz12 AS
    SELECT *
    FROM osm_landusages_gen1
    WHERE type IN ('wetland', 'marsh', 'swamp', 'bog', 'mud', 'tidalflat');

CREATE OR REPLACE VIEW landuse_overlay_z13toz14 AS
    SELECT *
    FROM osm_landusages
    WHERE type IN ('wetland', 'marsh', 'swamp', 'bog', 'mud', 'tidalflat');

CREATE OR REPLACE VIEW layer_landuse_overlay AS (
    SELECT osm_id, timestamp, geometry FROM landuse_overlay_z7
    UNION
    SELECT osm_id, timestamp, geometry FROM landuse_overlay_z8
    UNION
    SELECT osm_id, timestamp, geometry FROM landuse_overlay_z9
    UNION
    SELECT osm_id, timestamp, geometry FROM landuse_overlay_z10
    UNION
    SELECT osm_id, timestamp, geometry FROM landuse_overlay_z11toz12
    UNION
    SELECT osm_id, timestamp, geometry FROM landuse_overlay_z13toz14
);

CREATE OR REPLACE FUNCTION changed_tiles_landuse_overlay(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_geometries AS (
		    SELECT osm_id, geometry FROM layer_landuse_overlay
		    WHERE timestamp = ts
		), changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM changed_geometries AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry) AS t ON true
		)

		SELECT c.x, c.y, c.z FROM landuse_overlay_z13toz14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 13 AND 14
		UNION

		SELECT c.x, c.y, c.z FROM landuse_overlay_z11toz12 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 11 AND 12
		UNION

		SELECT c.x, c.y, c.z FROM landuse_overlay_z10 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 10
		UNION

		SELECT c.x, c.y, c.z FROM landuse_overlay_z9 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 9
		UNION

		SELECT c.x, c.y, c.z FROM landuse_overlay_z8 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 8
		UNION

		SELECT c.x, c.y, c.z FROM landuse_overlay_z7 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 7
	);
END;
$$ LANGUAGE plpgsql;


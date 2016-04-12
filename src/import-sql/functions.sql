CREATE OR REPLACE FUNCTION overlapping_tiles(
    geom geometry,
    max_zoom_level INTEGER
) RETURNS TABLE (
    tile_z INTEGER,
    tile_x INTEGER,
    tile_y INTEGER
) AS $$
BEGIN
    RETURN QUERY
        WITH RECURSIVE tiles(x, y, z, e) AS (
            SELECT 0, 0, 0, geom && CDB_XYZ_Extent(0, 0, 0)
            UNION ALL
            SELECT x*2 + xx, y*2 + yy, z+1,
                   geom && CDB_XYZ_Extent(x*2 + xx, y*2 + yy, z+1)
            FROM tiles,
            (VALUES (0, 0), (0, 1), (1, 1), (1, 0)) as c(xx, yy)
            WHERE e AND z < max_zoom_level
        )
        SELECT z, x, y FROM tiles WHERE e;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION changed_tiles_latest_timestamp()
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
DECLARE
	latest_ts timestamp;
BEGIN
	SELECT MAX(timestamp) INTO latest_ts FROM osm_timestamps;
	RETURN QUERY SELECT * FROM changed_tiles(latest_ts);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION deleted_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		SELECT DISTINCT t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		FROM osm_delete AS d
		INNER JOIN LATERAL overlapping_tiles(d.geometry, 14) AS t ON d.timestamp = ts
	);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
	    SELECT * FROM deleted_tiles(ts)
        UNION
	    SELECT * FROM admin_changed_tiles(ts)
	    UNION
	    SELECT * FROM aeroway_changed_tiles(ts)
	    UNION
	    SELECT * FROM barrier_line_changed_tiles(ts)
	    UNION
	    SELECT * FROM building_changed_tiles(ts)
	    UNION
	    SELECT * FROM housenum_label_changed_tiles(ts)
	    UNION
	    SELECT * FROM landuse_changed_tiles(ts)
	    UNION
	    SELECT * FROM landuse_overlay_changed_tiles(ts)
	    UNION
	    SELECT * FROM place_label_changed_tiles(ts)
	    UNION
	    SELECT * FROM poi_label_changed_tiles(ts)
	    UNION
	    SELECT * FROM road_changed_tiles(ts)
	    UNION
	    SELECT * FROM road_label_changed_tiles(ts)
	    UNION
	    SELECT * FROM water_changed_tiles(ts)
	    UNION
	    SELECT * FROM water_label_changed_tiles(ts)
	    UNION
	    SELECT * FROM waterway_changed_tiles(ts)
	    UNION
	    SELECT * FROM waterway_label_changed_tiles(ts)
        UNION
        SELECT * FROM mountain_peak_label_changed_tiles(ts)
        UNION
        SELECT * FROM airport_label_changed_tiles(ts)
        UNION
        SELECT * FROM rail_station_label_changed_tiles(ts)
	);
END;
$$ LANGUAGE plpgsql;

-- OSM ID transformations

CREATE OR REPLACE FUNCTION osm_id_point(osm_id BIGINT) RETURNS BIGINT AS $$
BEGIN
    RETURN (osm_id * 10);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION osm_id_linestring(osm_id BIGINT) RETURNS BIGINT AS $$
BEGIN
    RETURN CASE
        WHEN osm_id >= 0 THEN (osm_id * 10) + 1
        ELSE (osm_id * 10) + 3
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION osm_id_polygon(osm_id BIGINT) RETURNS BIGINT AS $$
BEGIN
    RETURN CASE
        WHEN osm_id >= 0 THEN (osm_id * 10) + 2
        ELSE (osm_id * 10) + 4
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION osm_id_geometry(osm_id BIGINT, geom geometry) RETURNS BIGINT AS $$
BEGIN RETURN CASE
        WHEN GeometryType(geom) = 'LINESTRING' THEN osm_id_linestring(osm_id)
        WHEN GeometryType(geom) = 'POINT' THEN osm_id_linestring(osm_id)
        WHEN GeometryType(geom) = 'POLYGON' THEN osm_id_polygon(osm_id)
      END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION overlapping_tiles(
    geom geometry,
    max_zoom_level INTEGER,
    buffer_size INTEGER
) RETURNS TABLE (
    tile_z INTEGER,
    tile_x INTEGER,
    tile_y INTEGER
) AS $$
BEGIN
    RETURN QUERY
        WITH RECURSIVE tiles(x, y, z, e) AS (
            SELECT 0, 0, 0, geom && XYZ_Extent(0, 0, 0, buffer_size)
            UNION ALL
            SELECT x*2 + xx, y*2 + yy, z+1,
                   geom && XYZ_Extent(x*2 + xx, y*2 + yy, z+1, buffer_size)
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

CREATE OR REPLACE FUNCTION changed_tiles_table(
    table_name TEXT,
    ts TIMESTAMP,
    buffer_size INTEGER,
    min_zoom INTEGER,
    max_zoom INTEGER
) RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
    RETURN QUERY EXECUTE format('
        SELECT DISTINCT t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
        FROM %I AS g
        INNER JOIN LATERAL overlapping_tiles(g.geometry, $2, $3)
                           AS t ON g.timestamp = $4
        WHERE 3 BETWEEN $1 AND $2
    ', table_name) USING min_zoom, max_zoom, buffer_size, ts;
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
        WHEN ST_GeometryType(geom) IN ('ST_LineString', 'ST_MultiLineString') THEN osm_id_linestring(osm_id)
        WHEN ST_GeometryType(geom) IN ('ST_Point', 'ST_MultiPoint') THEN osm_id_linestring(osm_id)
        WHEN ST_GeometryType(geom) IN ('ST_Polygon', 'ST_MuliPolygon') THEN osm_id_polygon(osm_id)
      END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

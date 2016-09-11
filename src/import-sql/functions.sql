CREATE OR REPLACE FUNCTION overlapping_tiles (
  geom geometry,
  max_zoom_level INTEGER,
  buffer_size INTEGER
) RETURNS TABLE (
  tile_z INTEGER,
  tile_x INTEGER,
  tile_y INTEGER
) AS $$
WITH RECURSIVE tiles(x, y, z, e) AS (
  SELECT
      0,
      0,
      0,
      geom && XYZ_Extent(0, 0, 0, buffer_size)
  UNION ALL
  SELECT
      x*2 + xx,
      y*2 + yy,
      z+1,
      geom && XYZ_Extent(x*2 + xx, y*2 + yy, z+1, buffer_size)
  FROM tiles,
    (VALUES (0, 0), (0, 1), (1, 1), (1, 0)) as c(xx, yy)
  WHERE e AND z < max_zoom_level
)
SELECT z, x, y FROM tiles WHERE e;
$$ LANGUAGE SQL IMMUTABLE;

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

-- specification : https://www.mapbox.com/vector-tiles/mapbox-streets-v7/
-- osm_ids :  imposm3 with use_single_id_space:true
CREATE OR REPLACE FUNCTION osm_ids2mbid (osm_ids BIGINT, is_polygon bool ) RETURNS BIGINT AS $$
  SELECT CASE
    WHEN                      (osm_ids >=     0::BIGINT )                    THEN ( (    osm_ids                ) * 10)       -- +0 point
    WHEN (NOT is_polygon) AND (osm_ids >= -1e17::BIGINT ) AND (osm_ids < 0 ) THEN ( (abs(osm_ids)               ) * 10) + 1   -- +1 way linestring
    WHEN (    is_polygon) AND (osm_ids >= -1e17::BIGINT ) AND (osm_ids < 0 ) THEN ( (abs(osm_ids)               ) * 10) + 2   -- +2 way poly
    WHEN (NOT is_polygon) AND (osm_ids <  -1e17::BIGINT )                    THEN ( (abs(osm_ids) - 1e17::bigint) * 10) + 3   -- +3 relations linestring
    WHEN (    is_polygon) AND (osm_ids <  -1e17::BIGINT )                    THEN ( (abs(osm_ids) - 1e17::bigint) * 10) + 4   -- +4 relations poly
    ELSE 0
  END;
$$ LANGUAGE SQL IMMUTABLE;


CREATE OR REPLACE FUNCTION is_polygon(geom geometry) RETURNS bool AS $$
  SELECT ST_GeometryType(geom) IN ('ST_Polygon', 'ST_MultiPolygon');
$$ LANGUAGE SQL IMMUTABLE;


/*
-- example call for osm_ids2mbid
select id
      ,osm_ids2mbid ( id,   is_polygon( geometry ) )  as from_real_geom
      ,osm_ids2mbid ( id,   false                  )  as from_fake_geom_false
      ,osm_ids2mbid ( id,   true                   )  as from_fake_geom_true
from osm_place_geometry ;
*/

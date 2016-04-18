CREATE OR REPLACE VIEW landuse_z5 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE type IN ('wood', 'forest')
      AND st_area(geometry) > 300000000;

CREATE OR REPLACE VIEW landuse_z6 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE type IN ('wood', 'forest')
      AND st_area(geometry) > 100000000;

CREATE OR REPLACE VIEW landuse_z7 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE type IN ('wood', 'forest')
      AND st_area(geometry) > 25000000;

CREATE OR REPLACE VIEW landuse_z8 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE type IN ('wood', 'forest')
      AND st_area(geometry) > 5000000;

CREATE OR REPLACE VIEW landuse_z9 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE type IN ('wood', 'forest')
      AND st_area(geometry) > 2000000;

CREATE OR REPLACE VIEW landuse_z10 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE type IN ('wood', 'forest')
      AND st_area(geometry) > 500000;

CREATE OR REPLACE VIEW landuse_z11 AS
    SELECT *
    FROM osm_landuse_polygon_gen1
    WHERE type IN ('wood', 'forest')
      AND st_area(geometry) > 100000;

CREATE OR REPLACE VIEW landuse_z12 AS
    SELECT *
    FROM osm_landuse_polygon
    WHERE type IN ('wood', 'forest')
      AND st_area(geometry) > 10000;

CREATE OR REPLACE VIEW landuse_z13toz14 AS
    SELECT *
    FROM osm_landuse_polygon
    WHERE type NOT IN ('wetland', 'marsh', 'swamp', 'bog', 'mud', 'tidalflat', 'national_park', 'nature_reserve', 'protected_area');

CREATE OR REPLACE VIEW landuse_geometries AS (
    SELECT osm_id, timestamp, geometry FROM osm_delete
    WHERE table_name = 'osm_landuse_polygon'
    UNION ALL
    SELECT osm_id, timestamp, geometry FROM osm_landuse_polygon
);

CREATE OR REPLACE FUNCTION landuse_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
DECLARE
    buffer_size CONSTANT integer := 4;
BEGIN
    RETURN QUERY (
        SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
        FROM landuse_layer AS c
        INNER JOIN LATERAL overlapping_tiles(c.geometry, 14, buffer_size)
                           AS t ON c.timestamp = ts
    );
END;
$$ LANGUAGE plpgsql;

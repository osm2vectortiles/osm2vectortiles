CREATE OR REPLACE FUNCTION is_landuse_overlay(type TEXT)
RETURNS BOOLEAN AS $$
BEGIN
	RETURN type IN ('wetland', 'marsh', 'swamp', 'bog', 'mud', 'tidalflat', 'national_park', 'nature_reserve', 'protected_area');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW landuse_overlay_z5 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE is_landuse_overlay(type) AND st_area(geometry) > 300000000;

CREATE OR REPLACE VIEW landuse_overlay_z6 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE is_landuse_overlay(type) AND st_area(geometry) > 100000000;

CREATE OR REPLACE VIEW landuse_overlay_z7 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE is_landuse_overlay(type) AND st_area(geometry) > 20000000;

CREATE OR REPLACE VIEW landuse_overlay_z8 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE is_landuse_overlay(type) AND st_area(geometry) > 6000000;

CREATE OR REPLACE VIEW landuse_overlay_z9 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE is_landuse_overlay(type) AND st_area(geometry) > 2000000;

CREATE OR REPLACE VIEW landuse_overlay_z10 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE is_landuse_overlay(type) AND st_area(geometry) > 500000;

CREATE OR REPLACE VIEW landuse_overlay_z11toz12 AS
    SELECT *
    FROM osm_landuse_polygon_gen1
    WHERE is_landuse_overlay(type);

CREATE OR REPLACE VIEW landuse_overlay_z13toz14 AS
    SELECT *
    FROM osm_landuse_polygon
    WHERE is_landuse_overlay(type);

CREATE OR REPLACE VIEW landuse_overlay_layer AS (
    SELECT osm_id, timestamp, geometry FROM landuse_overlay_z5
    UNION
    SELECT osm_id, timestamp, geometry FROM landuse_overlay_z6
    UNION
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

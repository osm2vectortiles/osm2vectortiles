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

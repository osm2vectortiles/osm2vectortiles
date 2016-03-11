CREATE OR REPLACE VIEW landuse_z5 AS
    SELECT *
    FROM osm_landusages_gen0
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 300000000;

CREATE OR REPLACE VIEW landuse_z6 AS
    SELECT *
    FROM osm_landusages_gen0
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 100000000;

CREATE OR REPLACE VIEW landuse_z7 AS
    SELECT *
    FROM osm_landusages_gen0
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 25000000;

CREATE OR REPLACE VIEW landuse_z8 AS
    SELECT *
    FROM osm_landusages_gen0
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 5000000;

CREATE OR REPLACE VIEW landuse_z9 AS
    SELECT *
    FROM osm_landusages_gen0
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 2000000;

CREATE OR REPLACE VIEW landuse_z10 AS
    SELECT *
    FROM osm_landusages_gen0
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 500000;

CREATE OR REPLACE VIEW landuse_z11 AS
    SELECT *
    FROM osm_landusages_gen1
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 100000;

CREATE OR REPLACE VIEW landuse_z12 AS
    SELECT *
    FROM osm_landusages
    WHERE type IN ('wood', 'nature_reserve', 'national_park', 'forest')
      AND st_area(geometry) > 10000;

CREATE OR REPLACE VIEW landuse_z13toz14 AS
    SELECT *
    FROM osm_landusages
    WHERE type NOT IN ('wetland', 'marsh', 'swamp', 'bog', 'mud', 'tidalflat');

CREATE VIEW layer_building AS (
    SELECT osm_id, timestamp, geometry FROM building_z13
    UNION
    SELECT osm_id, timestamp, geometry FROM building_z14
);

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

CREATE OR REPLACE VIEW landuse_z5toz6 AS
    SELECT osm_id, geometry, type
    FROM osm_landuse_polygon_gen0
    WHERE type IN ('wood', 'forest');

CREATE OR REPLACE VIEW landuse_z7toz8 AS
    SELECT osm_id, geometry, type
    FROM osm_landuse_polygon_gen0
    WHERE type IN ('wood', 'forest', 'residential')
      AND st_area(geometry) > 1000000;

CREATE OR REPLACE VIEW landuse_z9 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE landuse_class(type) IN ('wood', 'forest', 'residential', 'grass', 'cemetery', 'park', 'school')
      AND st_area(geometry) > 500000;

CREATE OR REPLACE VIEW landuse_z10 AS
    SELECT *
    FROM osm_landuse_polygon_gen0
    WHERE landuse_class(type) IN ('wood', 'forest', 'residential', 'commercial', 'retail', 'railway', 'industrial', 'grass', 'cemetery', 'park', 'school')
      AND st_area(geometry) > 99000;

CREATE OR REPLACE VIEW landuse_z11 AS
    SELECT *
    FROM osm_landuse_polygon_gen1
    WHERE landuse_class(type) IN ('wood', 'forest', 'residential','commercial', 'retail', 'railway', 'industrial', 'military', 'grass', 'cemetery', 'park', 'school', 'hospital')
      AND st_area(geometry) > 50000;

CREATE OR REPLACE VIEW landuse_z12 AS
    SELECT *
    FROM osm_landuse_polygon
    WHERE landuse_class(type) IN ('wood', 'forest', 'residential', 'grass','retail', 'railway', 'industrial', 'military', 'cemetery', 'park', 'school', 'hospital')
      AND st_area(geometry) > 10000;

CREATE OR REPLACE VIEW landuse_z13toz14 AS
    SELECT *
    FROM osm_landuse_polygon
    WHERE type NOT IN ('wetland', 'marsh', 'swamp', 'bog', 'mud', 'tidalflat', 'national_park', 'nature_reserve', 'protected_area');

CREATE OR REPLACE VIEW landuse_layer AS (
    SELECT osm_id FROM landuse_z5toz6
    UNION
    SELECT osm_id FROM landuse_z7toz8
    UNION
    SELECT osm_id FROM landuse_z9
    UNION
    SELECT osm_id FROM landuse_z10
    UNION
    SELECT osm_id FROM landuse_z11
    UNION
    SELECT osm_id FROM landuse_z12
    UNION
    SELECT osm_id FROM landuse_z13toz14
);

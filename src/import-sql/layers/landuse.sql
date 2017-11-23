DROP VIEW IF EXISTS landuse_z5toz6 CASCADE;
CREATE VIEW landuse_z5toz6 AS
    SELECT id AS osm_id, ST_Simplify(geometry, 2444) as geometry, type
    FROM osm_landuse_polygon_subdivided_gen0
    WHERE landuse_class(type) = 'wood'
      AND area > 10000000;

DROP VIEW IF EXISTS landuse_z7toz8 CASCADE;
CREATE VIEW landuse_z7toz8 AS
    SELECT id AS osm_id, ST_Simplify(geometry, 500) as geometry, type
    FROM osm_landuse_polygon_subdivided_gen0
    WHERE landuse_class(type) IN ('wood', 'residential')
      AND area > 1000000;

DROP VIEW IF EXISTS landuse_z9 CASCADE;
CREATE VIEW landuse_z9 AS
    SELECT id AS osm_id, ST_Simplify(geometry, 200) as geometry, type
    FROM osm_landuse_polygon_subdivided_gen0
    WHERE landuse_class(type) IN ('wood', 'residential', 'grass', 'cemetery', 'park', 'school')
      AND area > 500000;

DROP VIEW IF EXISTS landuse_z10 CASCADE;
CREATE VIEW landuse_z10 AS
    SELECT id AS osm_id, ST_Simplify(geometry, 77) as geometry, type
    FROM osm_landuse_polygon_subdivided_gen0
    WHERE landuse_class(type) IN ('wood', 'residential', 'commercial', 'retail', 'railway', 'industrial', 'grass', 'cemetery', 'park', 'school')
      AND area > 99000;

DROP VIEW IF EXISTS landuse_z11 CASCADE;
CREATE VIEW landuse_z11 AS
    SELECT id AS osm_id, ST_Simplify(geometry, 38) as geometry, type
    FROM osm_landuse_polygon_subdivided_gen1
    WHERE landuse_class(type) IN ('wood', 'residential','commercial', 'retail', 'railway', 'industrial', 'military', 'grass', 'cemetery', 'park', 'school', 'hospital')
      AND area > 50000;

DROP VIEW IF EXISTS landuse_z12 CASCADE;
CREATE VIEW landuse_z12 AS
    SELECT id AS osm_id, ST_Simplify(geometry, 19) as geometry, type
    FROM osm_landuse_polygon_subdivided
    WHERE landuse_class(type) IN ('wood', 'residential', 'grass','retail', 'railway', 'industrial', 'military', 'cemetery', 'park', 'school', 'hospital')
      AND area > 10000;

DROP VIEW IF EXISTS landuse_z13toz14 CASCADE;
CREATE OR REPLACE VIEW landuse_z13toz14 AS
    SELECT id AS osm_id, geometry, type
    FROM osm_landuse_polygon_subdivided
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

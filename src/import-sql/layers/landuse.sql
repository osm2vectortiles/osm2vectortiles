CREATE OR REPLACE VIEW landuse_z5toz6 AS
    SELECT id AS osm_id, geometry, type
    FROM (
        SELECT id, geometry, type FROM osm_landuse_polygon_gen0
        WHERE ST_Area(geometry) < 1000000000
        UNION ALL
        SELECT id, geometry, type FROM osm_landuse_split_polygon
    ) AS t
    WHERE landuse_class(type) = 'wood';

CREATE OR REPLACE VIEW landuse_z7toz8 AS
    SELECT id AS osm_id, geometry, type
    FROM (
        SELECT id, geometry, type FROM osm_landuse_polygon_gen0
        WHERE ST_Area(geometry) BETWEEN 1000000 AND 1000000000
        UNION ALL
        SELECT id, geometry, type FROM osm_landuse_split_polygon
    ) AS t
    WHERE landuse_class(type) IN ('wood', 'residential');

CREATE OR REPLACE VIEW landuse_z9 AS
    SELECT id AS osm_id, geometry, type
    FROM (
        SELECT id, geometry, type FROM osm_landuse_polygon_gen0
        WHERE ST_Area(geometry) BETWEEN 500000 AND 1000000000
        UNION ALL
        SELECT id, geometry, type FROM osm_landuse_split_polygon
    ) AS t
    WHERE landuse_class(type) IN ('wood', 'residential', 'grass', 'cemetery', 'park', 'school');

CREATE OR REPLACE VIEW landuse_z10 AS
    SELECT id AS osm_id, geometry, type
    FROM (
        SELECT id, geometry, type FROM osm_landuse_polygon_gen0
        WHERE ST_Area(geometry) BETWEEN 99000 AND 1000000000
        UNION ALL
        SELECT id, geometry, type FROM osm_landuse_split_polygon
    ) AS t
    WHERE landuse_class(type) IN ('wood', 'residential', 'commercial', 'retail', 'railway', 'industrial', 'grass', 'cemetery', 'park', 'school');

CREATE OR REPLACE VIEW landuse_z11 AS
    SELECT id AS osm_id, geometry, type
    FROM (
        SELECT id, geometry, type FROM osm_landuse_polygon_gen1
        WHERE ST_Area(geometry) BETWEEN 50000 AND 1000000000
        UNION ALL
        SELECT id, geometry, type FROM osm_landuse_split_polygon
    ) AS t
    WHERE landuse_class(type) IN ('wood', 'residential','commercial', 'retail', 'railway', 'industrial', 'military', 'grass', 'cemetery', 'park', 'school', 'hospital');

CREATE OR REPLACE VIEW landuse_z12 AS
    SELECT id AS osm_id, geometry, type
    FROM (
        SELECT id, geometry, type FROM osm_landuse_polygon
        WHERE ST_Area(geometry) BETWEEN 10000 AND 1000000000
        UNION ALL
        SELECT id, geometry, type FROM osm_landuse_split_polygon
    ) AS t
    WHERE landuse_class(type) IN ('wood', 'residential', 'grass','retail', 'railway', 'industrial', 'military', 'cemetery', 'park', 'school', 'hospital');

CREATE OR REPLACE VIEW landuse_z13toz14 AS
    SELECT id AS osm_id, geometry, type
    FROM (
        SELECT id, geometry, type FROM osm_landuse_polygon
        WHERE ST_Area(geometry) < 1000000000
        UNION ALL
        SELECT id, geometry, type FROM osm_landuse_split_polygon
    ) AS t
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

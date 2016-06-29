CREATE OR REPLACE VIEW poi_label_z14 AS (
    SELECT * FROM (
        SELECT geometry, id AS osm_id, ref, name, name_en, name_es, name_fr,
        name_de, name_ru, name_zh, type, 0 AS area
        FROM osm_poi_point
        UNION ALL
        SELECT geometry, id AS osm_id, ref, name, name_en, name_es, name_fr,
        name_de, name_ru, name_zh, type, area
        FROM osm_poi_polygon
    ) AS poi_geoms
    -- Nameless POIs must have distinct maki label not the generic default
    WHERE maki_label_class(type) <> '' OR name <> ''
);

CREATE OR REPLACE VIEW poi_label_layer AS (
    SELECT osm_id FROM poi_label_z14
);

CREATE OR REPLACE FUNCTION poi_label_localrank(type VARCHAR, name VARCHAR) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE
        -- Nameless POIs should have the maximal localrank and least priority
        WHEN name = '' THEN 2000
        WHEN type IN ('station', 'subway_entrance', 'park', 'cemetery', 'bank', 'supermarket', 'car', 'library', 'university', 'college', 'police', 'townhall', 'courthouse') THEN 2
        WHEN type IN ('nature_reserve', 'garden', 'public_building') THEN 3
        WHEN type IN ('stadium') THEN 90
        WHEN type IN ('hospital') THEN 100
        WHEN type IN ('zoo') THEN 200
        WHEN type IN ('university', 'school', 'college', 'kindergarten') THEN 300
        WHEN type IN ('supermarket', 'department_store') THEN 400
        WHEN type IN ('nature_reserve', 'swimming_area') THEN 500
        WHEN type IN ('attraction') THEN 600
        ELSE 1000
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION poi_label_scalerank(type VARCHAR, area REAL) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE
        WHEN area > 145000 THEN 1
        WHEN area > 12780 THEN 2
        WHEN area > 2960 THEN 3
        WHEN type IN ('station') THEN 1
        ELSE 4
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION format_type(class VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN REPLACE(INITCAP(class), '_', ' ');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

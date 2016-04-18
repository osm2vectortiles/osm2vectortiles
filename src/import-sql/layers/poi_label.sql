CREATE OR REPLACE VIEW poi_label_z14 AS (
    SELECT * FROM (
        SELECT geometry, osm_id, ref, name, name_en, name_es, name_fr,
        name_de, name_ru, name_zh, type, 0 AS area, timestamp
        FROM osm_poi_point
        UNION ALL
        SELECT geometry, osm_id, ref, name, name_en, name_es, name_fr,
        name_de, name_ru, name_zh, type, area, timestamp
        FROM osm_poi_polygon
    ) AS poi_geoms
    WHERE name IS NOT NULL AND name <> ''
);

CREATE OR REPLACE VIEW poi_label_layer AS (
    SELECT osm_id, timestamp, geometry FROM poi_label_z14
);

CREATE OR REPLACE FUNCTION poi_label_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
DECLARE
    buffer_size CONSTANT integer := 128;
BEGIN
    RETURN QUERY (
        WITH geoms AS (
            SELECT osm_id, timestamp, geometry FROM osm_delete
            WHERE table_name = 'osm_poi_point'
               OR table_name = 'osm_poi_polygon'
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_poi_point
            UNION ALL
            SELECT osm_id, timestamp, geometry FROM osm_poi_polygon
        )
        SELECT DISTINCT t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
        FROM geoms AS c
        INNER JOIN LATERAL overlapping_tiles(c.geometry, 14, buffer_size)
                           AS t ON c.timestamp = ts
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION poi_label_localrank(type VARCHAR) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE
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

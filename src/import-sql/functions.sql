CREATE OR REPLACE FUNCTION localrank_poi(type VARCHAR) RETURNS INTEGER
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

CREATE OR REPLACE FUNCTION localrank_road(type VARCHAR) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE
        WHEN type IN ('motorway') THEN 10
        WHEN type IN ('trunk') THEN 20
        WHEN type IN ('primary') THEN 30
        WHEN type IN ('secondary') THEN 40
        WHEN type IN ('tertiary') THEN 50
        ELSE 100
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION normalize_scalerank(scalerank INTEGER) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE
        WHEN scalerank >= 9 THEN 9
        ELSE scalerank
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION scalerank_poi(type VARCHAR, area REAL) RETURNS INTEGER
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

CREATE OR REPLACE FUNCTION classify_road_railway(type VARCHAR, service VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN type = 'rail' AND service IN ('yard', 'siding', 'spur', 'crossover') THEN 'minor_rail'
        ELSE classify_road(type)
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION poi_address(housenumber VARCHAR, street VARCHAR, place VARCHAR, city VARCHAR, country VARCHAR, postcode VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN concat_ws(' ', housenumber, street, place, city, country, postcode);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION poi_network(type VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN type IN ('station') THEN 'rail'
        ELSE ''
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION format_type(class VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN REPLACE(INITCAP(class), '_', ' ');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION detect_dirty_tiles(
    view_name VARCHAR,
    ts timestamp
) RETURNS TABLE (
    z INTEGER,
    x INTEGER,
    y INTEGER
) AS $$
BEGIN
    RETURN QUERY EXECUTE 'WITH RECURSIVE dirty_tiles(x, y, z, e) AS ('
        'SELECT 0, 0, 0, EXISTS('
        'SELECT 1 FROM changed_poi_points '
        'WHERE geometry && CDB_XYZ_Extent(0, 0, 0)'
        ')'
        'UNION ALL '
        'SELECT x*2 + xx, y*2 + yy, z+1, EXISTS('
        'SELECT 1 FROM changed_poi_points '
        'WHERE geometry && CDB_XYZ_Extent(x*2 + xx, y*2 + yy, z+1)'
        ') FROM dirty_tiles,'
        '(VALUES (0, 0), (0, 1), (1, 1), (1, 0)) as c(xx, yy)'
        'WHERE e AND z < 14'
        '), changed_poi_points AS ('
        'SELECT * FROM ' || quote_ident(view_name) || ' WHERE timestamp = $1'
        ')'
        'SELECT z, x, y FROM dirty_tiles where e;'
	USING ts;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION overlapping_tiles(
    geom geometry,
    max_zoom_level INTEGER
) RETURNS TABLE (
    tile_z INTEGER,
    tile_x INTEGER,
    tile_y INTEGER
) AS $$
BEGIN
    RETURN QUERY
        WITH RECURSIVE tiles(x, y, z, e) AS (
            SELECT 0, 0, 0, geom && CDB_XYZ_Extent(0, 0, 0)
            UNION ALL
            SELECT x*2 + xx, y*2 + yy, z+1,
                   geom && CDB_XYZ_Extent(x*2 + xx, y*2 + yy, z+1)
            FROM tiles,
            (VALUES (0, 0), (0, 1), (1, 1), (1, 0)) as c(xx, yy)
            WHERE e AND z < max_zoom_level
        )
        SELECT z, x, y FROM tiles WHERE e;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION changed_tiles_landuse(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_geometries AS (
		    SELECT osm_id, geometry FROM poi_label_zoom_level_changes
		    WHERE timestamp = ts
		), changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM changed_geometries AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON true
		)

		SELECT c.x, c.y, c.z FROM landuse_z13toz14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 13 AND 14
		UNION

		SELECT c.x, c.y, c.z FROM landuse_z12 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 12
		UNION

		SELECT c.x, c.y, c.z FROM landuse_z11 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 11
		UNION

		SELECT c.x, c.y, c.z FROM landuse_z10 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 10
		UNION

		SELECT c.x, c.y, c.z FROM landuse_z9 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 9
		UNION

		SELECT c.x, c.y, c.z FROM landuse_z8 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 8
		UNION

		SELECT c.x, c.y, c.z FROM landuse_z7 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 7
		UNION

		SELECT c.x, c.y, c.z FROM landuse_z6 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 6
		UNION
		SELECT c.x, c.y, c.z FROM landuse_z5 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 5
	);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION changed_tiles_poi_label(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_geometries AS (
		    SELECT osm_id, geometry FROM layer_poi_label
		    WHERE timestamp = ts
		), changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM changed_geometries AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON true
		)

		SELECT c.x, c.y, c.z FROM poi_label_z14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 14
	);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION changed_tiles_place_label(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_geometries AS (
		    SELECT osm_id, geometry FROM layer_place_label
		    WHERE timestamp = ts
		), changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM changed_geometries AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry) AS t ON true
		)

		SELECT c.x, c.y, c.z FROM place_label_z14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 14
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z13 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 13
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z11toz12 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 11 AND 12
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z9toz10 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 9 AND 10
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z8 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 8
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z7 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 7
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z6 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 6
		UNION

		SELECT c.x, c.y, c.z FROM place_label_z4toz5 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 4 AND 5
	);
END;
$$ LANGUAGE plpgsql;

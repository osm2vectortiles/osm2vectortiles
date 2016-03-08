CREATE TYPE tile AS (x INTEGER, y INTEGER, z INTEGER);
CREATE TYPE tile_fraction AS (x DOUBLE PRECISION, y DOUBLE PRECISION, z INTEGER);


CREATE OR REPLACE FUNCTION linestring_to_tiles(
    linestring geometry,
    zoom_level INTEGER
) RETURNS tile[]
AS $$
DECLARE
	t tile;
	tiles tile[];
	coords GEOMETRY[];
	prev GEOMETRY;
	start tile;
	stop tile;
	x DOUBLE PRECISION;
	y DOUBLE PRECISION;
	dx DOUBLE PRECISION;
	dy DOUBLE PRECISION;
	sx INTEGER;
	sy INTEGER;
	tMaxX DOUBLE PRECISION;
	tMaxY DOUBLE PRECISION;
	tdx DOUBLE PRECISION;
	tdy DOUBLE PRECISION;
BEGIN
	coords := ARRAY(SELECT geom(ST_DumpPoints(linestring)));
	FOR i IN array_lower(coords, 1) .. array_upper(coords, 1)
    LOOP
      start := point_to_tile_fraction(coords[i], zoom_level);
      stop := point_to_tile_fraction(coords[i + 1], zoom_level);

      dx := x(stop) - x(start);
      dy := y(stop) - y(start);

      CONTINUE WHEN dx = 0 AND dy = 0;

      sx := CASE WHEN dx > 0 THEN 1 ELSE -1 END;
      sy := CASE WHEN dy > 0 THEN 1 ELSE -1 END;
      x := floor(x(start));
      y := floor(y(start));

      tMaxX := CASE WHEN dx = 0 THEN 'Infinity' ELSE abs(((CASE WHEN dx > 0 THEN 1 ELSE 0 END) + x - x(start)) / dx) END;
      tMaxY := CASE WHEN dy = 0 THEN 'Infinity' ELSE abs(((CASE WHEN dy > 0 THEN 1 ELSE 0 END) + y - y(start)) / dy) END;
      tdx := abs(sx / (dx + 0.000000000000001));
      tdy := abs(sy / (dy + 0.000000000000001));

      IF x <> st_x(prev) OR y <> st_y(prev) THEN
        SELECT x, y, zoom_level INTO t;
      	tiles := array_append(tiles, t);
        prev := start;
	  END IF;   

	  WHILE tMaxX < 1 OR tMaxY < 1 LOOP
	        IF tMaxX < tMaxY THEN
                tMaxX := tMaxX + tdx;
                x := x + sx;
            ELSE
                tMaxY := tMaxY + tdy;
                y := y + sy;
            END IF;

            SELECT x, y, zoom_level INTO t;
			tiles := array_append(tiles, t);
			prev := ST_MakePoint(x, y);
	  END LOOP;

    END LOOP;
	RETURN tiles;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION linestring_to_tiles(
    linestring geometry,
    zoom_level INTEGER
) RETURNS tile[]
AS $$
DECLARE
	tiles tile[];
	coords GEOMETRY[];
	prev GEOMETRY;
	start tile;
	stop tile;
BEGIN
	coords := ARRAY(SELECT geom(ST_DumpPoints(linestring)));
	FOR i IN array_lower(coords, 1) .. array_upper(coords, 1)
    LOOP
      start := point_to_tile_fraction(coords[i], zoom_level);
      stop := point_to_tile_fraction(coords[i + 1], zoom_level);
      tiles := array_append(tiles, start);
      tiles := array_append(tiles, stop);
    END LOOP;
	RETURN tiles;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION point_to_tile_fraction(
    _point geometry,
    zoom_level INTEGER
) RETURNS tile_fraction
AS $$
DECLARE
    d2r CONSTANT DOUBLE PRECISION := pi() / 180;
    lon CONSTANT DOUBLE PRECISION := st_x(ST_Transform(_point, 4326));
    lat CONSTANT DOUBLE PRECISION := st_y(ST_Transform(_point, 4326));
    z2 CONSTANT DOUBLE PRECISION := pow(2, zoom_level);
    _sin CONSTANT DOUBLE PRECISION := sin(lat * d2r);
    t tile;
BEGIN
    t.x = z2 * (lon / 360 + 0.5);
    t.y = z2 * (0.5 - 0.25 * log((1 + _sin) / (1 - _sin)) / pi());
    t.z = zoom_level;
    RETURN t;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION point_to_tile(
    _point geometry,
    zoom_level INTEGER
) RETURNS tile
AS $$
DECLARE
	tf tile_fraction;
    t tile;
BEGIN
	tf := point_to_tile_fraction(_point, zoom_level); 
    t.x = floor(tf.x);
    t.y = floor(tf.y);
    t.z = tf.z;
    RETURN t;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

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

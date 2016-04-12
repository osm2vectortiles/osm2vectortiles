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

CREATE OR REPLACE FUNCTION scalerank_airport_label(maki VARCHAR, area REAL, aerodrome VARCHAR) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE
        WHEN (maki = 'airport' AND area >= 300000) OR aerodrome = 'international' THEN 1
        WHEN maki = 'airport' AND area < 300000 THEN 2
        WHEN maki = 'airfield' AND area >= 145000 THEN 3
        WHEN maki = 'airfield' AND area < 145000 THEN 4
        ELSE 4
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION road_class(type VARCHAR, service VARCHAR, access VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN type = 'rail' AND service IN ('yard', 'siding', 'spur', 'crossover') THEN 'minor_rail'
        WHEN access IN ('no', 'private', 'permissive', 'agriculture', 'use_sidepath', 'delivery', 'designated', 'dismount', 'discouraged', 'forestry', 'destination', 'customers') THEN 'street_limited'
        ELSE classify_road(type)
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION road_type(class VARCHAR, type VARCHAR, construction VARCHAR, tracktype VARCHAR, service VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN class = 'construction' THEN road_type_value(class, construction)
        WHEN class = 'track' THEN road_type_value(class, tracktype)
        WHEN class = 'service' THEN road_type_value(class, service)
        WHEN class = 'golf' THEN 'golf'
        WHEN class IN ('major_rail', 'minor_rail') THEN 'rail'
        WHEN class = 'mtb' THEN 'mountain_bike'
        WHEN class = 'aerialway' AND type IN ('gondola', 'mixed_lift', 'chair_lift') THEN road_type_value(class, type)
        WHEN class = 'aerialway' AND type = 'cable_car' THEN 'aerialway:cablecar'
        WHEN class = 'aerialway' AND type IN ('drag_lift', 't-bar', 'j-bar', 'platter', 'rope_tow', 'zip_line') THEN 'aerialway:drag_lift'
        WHEN class = 'aerialway' AND type IN ('magic_carpet', 'canopy') THEN 'aerialway:magic_carpet'
        ELSE type
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION road_type_value(left_value VARCHAR, right_value VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    IF right_value = '' OR right_value IS NULL THEN
        RETURN left_value;
    ELSE
        RETURN left_value || ':' || right_value;
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION road_oneway(oneway INTEGER) RETURNS VARCHAR
AS $$
BEGIN
    IF oneway = 1 THEN
        RETURN 'true';
    ELSE
        RETURN 'false';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION classify_airport_label(kind VARCHAR, type VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN kind = 'heliport' THEN 'heliport'
        WHEN kind = 'aerodrome' AND type IN ('public', 'Public') THEN 'airport'
        WHEN kind = 'aerodrome' AND type IN ('private', 'Private', 'military/public', 'Military/Public') THEN 'airfield'
        ELSE 'airfield'
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION classify_structure(is_tunnel BOOLEAN, is_bridge BOOLEAN, is_ford BOOLEAN) RETURNS VARCHAR
AS $$
BEGIN
    IF is_tunnel THEN
        RETURN 'tunnel';
    ELSIF is_bridge THEN
        RETURN 'bridge';
    ELSIF is_ford THEN
        RETURN 'ford';
    ELSE
        RETURN 'none';
    END IF;
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

CREATE OR REPLACE FUNCTION meter_to_feet(meter INTEGER) RETURNS INTEGER
AS $$
BEGIN
    RETURN round(meter * 3.28084);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION is_underground(level INTEGER) RETURNS VARCHAR
AS $$
BEGIN
    IF level >= 1 THEN
        RETURN 'true';
    ELSE
        RETURN 'false';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION mountain_peak_type(type VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    IF type = 'volcano' THEN
        RETURN type;
    ELSE
        RETURN 'mountain';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

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
            SELECT 0, 0, 0, geom && XYZ_Extent(0, 0, 0)
            UNION ALL
            SELECT x*2 + xx, y*2 + yy, z+1,
                   geom && XYZ_Extent(x*2 + xx, y*2 + yy, z+1)
            FROM tiles,
            (VALUES (0, 0), (0, 1), (1, 1), (1, 0)) as c(xx, yy)
            WHERE e AND z < max_zoom_level
        )
        SELECT z, x, y FROM tiles WHERE e;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION changed_tiles_latest_timestamp()
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
DECLARE
	latest_ts timestamp;
BEGIN
	SELECT MAX(timestamp) INTO latest_ts FROM osm_timestamps;
	RETURN QUERY SELECT * FROM changed_tiles(latest_ts);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION deleted_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		SELECT DISTINCT t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		FROM osm_delete AS d
		INNER JOIN LATERAL overlapping_tiles(d.geometry, 14) AS t ON d.timestamp = ts
	);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
	    SELECT * FROM deleted_tiles(ts)
        UNION
	    SELECT * FROM changed_tiles_admin(ts)
	    UNION
	    SELECT * FROM changed_tiles_aeroway(ts)
	    UNION
	    SELECT * FROM changed_tiles_barrier_line(ts)
	    UNION
	    SELECT * FROM changed_tiles_building(ts)
	    UNION
	    SELECT * FROM changed_tiles_housenum_label(ts)
	    UNION
	    SELECT * FROM changed_tiles_landuse(ts)
	    UNION
	    SELECT * FROM changed_tiles_landuse_overlay(ts)
	    UNION
	    SELECT * FROM changed_tiles_place_label(ts)
	    UNION
	    SELECT * FROM changed_tiles_poi_label(ts)
	    UNION
	    SELECT * FROM changed_tiles_road(ts)
	    UNION
	    SELECT * FROM changed_tiles_road_label(ts)
	    UNION
	    SELECT * FROM changed_tiles_water(ts)
	    UNION
	    SELECT * FROM changed_tiles_water_label(ts)
	    UNION
	    SELECT * FROM changed_tiles_waterway(ts)
	    UNION
	    SELECT * FROM changed_tiles_waterway_label(ts)
        UNION
        SELECT * FROM changed_tiles_mountain_peak_label(ts)
        UNION
        SELECT * FROM changed_tiles_airport_label(ts)
        UNION
        SELECT * FROM changed_tiles_rail_station_label(ts)
	);
END;
$$ LANGUAGE plpgsql;

-- OSM ID transformations

CREATE OR REPLACE FUNCTION osm_id_point(osm_id BIGINT) RETURNS BIGINT AS $$
BEGIN
    RETURN (osm_id * 10);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION osm_id_linestring(osm_id BIGINT) RETURNS BIGINT AS $$
BEGIN
    RETURN CASE
        WHEN osm_id >= 0 THEN (osm_id * 10) + 1
        ELSE (osm_id * 10) + 3
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION osm_id_polygon(osm_id BIGINT) RETURNS BIGINT AS $$
BEGIN
    RETURN CASE
        WHEN osm_id >= 0 THEN (osm_id * 10) + 2
        ELSE (osm_id * 10) + 4
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION osm_id_geometry(osm_id BIGINT, geom geometry) RETURNS BIGINT AS $$
BEGIN RETURN CASE
        WHEN GeometryType(geom) = 'LINESTRING' THEN osm_id_linestring(osm_id)
        WHEN GeometryType(geom) = 'POINT' THEN osm_id_linestring(osm_id)
        WHEN GeometryType(geom) = 'POLYGON' THEN osm_id_polygon(osm_id)
      END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

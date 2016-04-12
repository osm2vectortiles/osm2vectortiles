CREATE OR REPLACE VIEW road_z5toz6 AS
    SELECT osm_id, geometry, type, construction, tracktype, service, access, oneway, 'none' AS structure, z_order, timestamp
    FROM osm_road_geometry
    WHERE type IN ('motorway', 'trunk');

CREATE OR REPLACE VIEW road_z7 AS
    SELECT osm_id, geometry, type, construction, tracktype, service, access, oneway, 'none' AS structure, z_order, timestamp
    FROM osm_road_geometry
    WHERE type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link');

CREATE OR REPLACE VIEW road_z8toz10 AS
    SELECT osm_id, geometry, type, construction, tracktype, service, access, oneway, 'none' AS structure, z_order, timestamp
    FROM osm_road_geometry
    WHERE type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link', 'secondary', 'secondary_link');

CREATE OR REPLACE VIEW road_z11 AS
    SELECT osm_id, geometry, type, construction, tracktype, service, access, oneway, 'none' AS structure, z_order, timestamp
    FROM osm_road_geometry
    WHERE type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link', 'secondary', 'secondary_link', 'tertiary', 'teriary_link');

CREATE OR REPLACE VIEW road_z12 AS
    SELECT osm_id, geometry, type, construction, tracktype, service, access, oneway, 'none' AS structure, z_order, timestamp
    FROM osm_road_geometry
    WHERE classify_road(type) IN ('major_rail', 'street')
      AND type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link', 'secondary', 'secondary_link', 'tertiary', 'teriary_link');

CREATE OR REPLACE VIEW road_z13 AS
    SELECT osm_id, geometry, type, construction, tracktype, service, access, oneway, classify_structure(is_tunnel, is_bridge, is_ford) AS structure, z_order, timestamp
    FROM osm_road_geometry
    WHERE classify_road(type) IN ('minor_rail', 'street_limited', 'service')
      AND type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link', 'secondary', 'secondary_link', 'tertiary', 'teriary_link');

CREATE OR REPLACE VIEW road_z14 AS
    SELECT osm_id, geometry, type, construction, tracktype, service, access, oneway, classify_structure(is_tunnel, is_bridge, is_ford) AS structure, z_order, timestamp
    FROM osm_road_geometry;

CREATE OR REPLACE VIEW road_layer AS (
    SELECT osm_id, timestamp, geometry FROM road_z5toz6
    UNION
    SELECT osm_id, timestamp, geometry FROM road_z7
    UNION
    SELECT osm_id, timestamp, geometry FROM road_z8toz10
    UNION
    SELECT osm_id, timestamp, geometry FROM road_z11
    UNION
    SELECT osm_id, timestamp, geometry FROM road_z12
    UNION
    SELECT osm_id, timestamp, geometry FROM road_z13
    UNION
    SELECT osm_id, timestamp, geometry FROM road_z14
);

CREATE OR REPLACE FUNCTION road_changed_tiles(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM road_layer AS c
        INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON c.timestamp = ts
		)

		SELECT c.x, c.y, c.z FROM road_z14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 14
		UNION

		SELECT c.x, c.y, c.z FROM road_z13 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 13
		UNION

		SELECT c.x, c.y, c.z FROM road_z12 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 12
		UNION

		SELECT c.x, c.y, c.z FROM road_z11 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 11
		UNION

		SELECT c.x, c.y, c.z FROM road_z8toz10 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 8 AND 10
		UNION

		SELECT c.x, c.y, c.z FROM road_z7 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 7
		UNION

		SELECT c.x, c.y, c.z FROM road_z5toz6 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z BETWEEN 5 AND 6 
	);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION road_localrank(type VARCHAR) RETURNS INTEGER
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

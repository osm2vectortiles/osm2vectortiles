CREATE OR REPLACE FUNCTION road_structure(is_tunnel BOOLEAN, is_bridge BOOLEAN, is_ford BOOLEAN) RETURNS VARCHAR
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

CREATE OR REPLACE FUNCTION road_class(type VARCHAR, service VARCHAR, access VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN road_type_class(type) = 'major_rail' AND service IN ('yard', 'siding', 'spur', 'crossover') THEN 'minor_rail'
        WHEN road_type_class(type) = 'street' AND access IN ('no', 'private') THEN 'street_limited'
        ELSE road_type_class(type)
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

DROP VIEW IF EXISTS road_z5 CASCADE;
CREATE VIEW road_z5 AS
    SELECT id AS osm_id, ST_Simplify(geometry, 2444) as geometry, type, construction, tracktype, service, access, oneway, 'none'::varchar(4) AS structure, z_order
    FROM osm_road_geometry
    WHERE road_class(type, service, access) IN ('motorway', 'trunk');

DROP VIEW IF EXISTS road_z6toz7 CASCADE;
CREATE VIEW road_z6toz7 AS
    SELECT id AS osm_id, ST_Simplify(geometry, 916) as geometry, type, construction, tracktype, service, access, oneway, 'none'::varchar(4) AS structure, z_order
    FROM osm_road_geometry
    WHERE road_class(type, service, access) IN ('motorway', 'trunk', 'primary');

DROP VIEW IF EXISTS road_z8toz9 CASCADE;
CREATE VIEW road_z8toz9 AS
    SELECT id AS osm_id, ST_Simplify(geometry, 229) as geometry, type, construction, tracktype, service, access, oneway, 'none'::varchar(4) AS structure, z_order
    FROM osm_road_geometry
    WHERE road_class(type, service, access) IN ('motorway', 'motorway_link', 'trunk', 'primary', 'secondary', 'major_rail');

DROP VIEW IF EXISTS road_z10 CASCADE;
CREATE VIEW road_z10 AS
    SELECT id AS osm_id, ST_Simplify(geometry, 77) as geometry, type, construction, tracktype, service, access, oneway, 'none'::varchar(4) AS structure, z_order
    FROM osm_road_geometry
    WHERE road_class(type, service, access) IN ('motorway', 'motorway_link', 'trunk', 'primary', 'secondary', 'tertiary', 'major_rail');

DROP VIEW IF EXISTS road_z11 CASCADE;
CREATE VIEW road_z11 AS
    SELECT id AS osm_id, ST_Simplify(geometry, 38) as geometry, type, construction, tracktype, service, access, oneway, 'none'::varchar(4) AS structure, z_order
    FROM osm_road_geometry
    WHERE road_class(type, service, access) IN ('motorway', 'motorway_link', 'trunk', 'primary', 'secondary', 'tertiary', 'major_rail', 'street', 'ferry');

DROP VIEW IF EXISTS road_z12 CASCADE;
CREATE VIEW road_z12 AS
    SELECT id AS osm_id, ST_Simplify(geometry, 19) as geometry, type, construction, tracktype, service, access, oneway, 'none'::varchar(4) AS structure, z_order
    FROM osm_road_geometry
    WHERE road_type_class(type) IN ('motorway', 'motorway_link', 'trunk', 'primary', 'secondary', 'tertiary', 'major_rail', 'street', 'ferry', 'pedestrian', 'service', 'link', 'construction', 'street_limited', 'aerialway');

DROP VIEW IF EXISTS road_z13 CASCADE;
CREATE VIEW road_z13 AS
    SELECT id AS osm_id, ST_Simplify(geometry, 9) as geometry, type, construction, tracktype, service, access, oneway, road_structure(is_tunnel, is_bridge, is_ford) AS structure, z_order
    FROM osm_road_geometry
    WHERE road_type_class(type) IN ('motorway', 'motorway_link', 'trunk', 'primary', 'secondary', 'tertiary', 'major_rail', 'street', 'ferry', 'pedestrian', 'service', 'link', 'construction', 'street_limited', 'aerialway', 'track');

DROP VIEW IF EXISTS road_z14 CASCADE;
CREATE OR REPLACE VIEW road_z14 AS
    SELECT id AS osm_id, geometry, type, construction, tracktype, service, access, oneway, road_structure(is_tunnel, is_bridge, is_ford) AS structure, z_order
    FROM osm_road_geometry;

CREATE OR REPLACE VIEW road_layer AS (
    SELECT osm_id FROM road_z5
    UNION
    SELECT osm_id FROM road_z6toz7
    UNION
    SELECT osm_id FROM road_z8toz9
    UNION
    SELECT osm_id FROM road_z10
    UNION
    SELECT osm_id FROM road_z11
    UNION
    SELECT osm_id FROM road_z12
    UNION
    SELECT osm_id FROM road_z13
    UNION
    SELECT osm_id FROM road_z14
);

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

CREATE OR REPLACE FUNCTION road_type(class VARCHAR, type VARCHAR, construction VARCHAR, tracktype VARCHAR, service VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN class = 'construction' THEN road_type_value(class, construction)
        WHEN class = 'track' THEN road_type_value(class, tracktype)
        WHEN class = 'service' THEN road_type_value(class, service)
        WHEN class = 'golf' THEN 'golf'
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

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

CREATE OR REPLACE VIEW layer_road AS (
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

CREATE OR REPLACE FUNCTION changed_tiles_road(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM layer_road AS c
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


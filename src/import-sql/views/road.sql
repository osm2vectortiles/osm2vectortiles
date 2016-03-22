CREATE OR REPLACE VIEW osm_unique_road AS (
    SELECT rp.osm_id, rp.geometry, rp.type, rp.service,
           rp.oneway, rp.is_bridge, rp.is_tunnel, rp.timestamp,
           rp.ref, rp.name, rp.name_en, rp.name_es,
           rp.name_fr, rp.name_de, rp.name_ru, rp.name_zh,
           rp.layer, rp.z_order
    FROM osm_road_polygon AS rp
    UNION ALL
    SELECT rl.osm_id, rl.geometry, rl.type, rl.service,
           rl.oneway, rl.is_bridge, rl.is_tunnel, rl.timestamp,
           rl.ref, rl.name, rl.name_en, rl.name_es,
           rl.name_fr, rl.name_de, rl.name_ru, rl.name_zh,
           rl.layer, rp.z_order
    FROM osm_road_linestring AS rl
    LEFT JOIN osm_road_polygon AS rp ON rp.osm_id = rl.osm_id
    WHERE rp.osm_id IS NULL
);

CREATE OR REPLACE VIEW road_z5toz6 AS
    SELECT *
    FROM osm_unique_road
    WHERE type IN ('motorway', 'trunk');

CREATE OR REPLACE VIEW road_z7 AS
    SELECT *
    FROM osm_unique_road
    WHERE type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link');

CREATE OR REPLACE VIEW road_z8toz10 AS
    SELECT *
    FROM osm_unique_road
    WHERE type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link', 'secondary', 'secondary_link');

CREATE OR REPLACE VIEW road_z11 AS
    SELECT *
    FROM osm_unique_road
    WHERE type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link', 'secondary', 'secondary_link', 'tertiary', 'teriary_link');

CREATE OR REPLACE VIEW road_z12 AS
    SELECT *
    FROM osm_unique_road
    WHERE classify_road(type) IN ('major_rail', 'street')
      AND type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link', 'secondary', 'secondary_link', 'tertiary', 'teriary_link')
      AND NOT is_bridge
      AND NOT is_tunnel;

CREATE OR REPLACE VIEW road_z13 AS
    SELECT *
    FROM osm_unique_road
    WHERE classify_road(type) IN ('minor_rail', 'street_limited', 'service')
      AND type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link', 'secondary', 'secondary_link', 'tertiary', 'teriary_link')
      AND NOT is_bridge
      AND NOT is_tunnel;

CREATE OR REPLACE VIEW road_z14 AS
    SELECT *
    FROM osm_unique_road
    WHERE NOT is_bridge
      AND NOT is_tunnel;

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
		WITH changed_geometries AS (
        SELECT osm_id, timestamp, geometry FROM osm_delete
        WHERE table_name = 'osm_road_linestring' OR table_name = 'osm_road_polygon'
        UNION
		    SELECT osm_id, timestamp, geometry FROM layer_road
		), changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM changed_geometries AS c
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


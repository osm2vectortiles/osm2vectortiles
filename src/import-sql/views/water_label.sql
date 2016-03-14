CREATE OR REPLACE VIEW water_label_z10 AS
    SELECT osm_id, topoint(geometry) as geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh, timestamp
    FROM osm_water_polygons
    WHERE area >= 100000000;

CREATE OR REPLACE VIEW water_label_z11 AS
    SELECT osm_id, topoint(geometry) as geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh, timestamp
    FROM osm_water_polygons
    WHERE area >= 40000000;

CREATE OR REPLACE VIEW water_label_z12 AS
    SELECT osm_id, topoint(geometry) as geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh, timestamp
    FROM osm_water_polygons
    WHERE area >= 20000000;

CREATE OR REPLACE VIEW water_label_z13 AS
    SELECT osm_id, topoint(geometry) as geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh, timestamp
    FROM osm_water_polygons
    WHERE area >= 10000000;

CREATE OR REPLACE VIEW water_label_z14 AS
    SELECT osm_id, topoint(geometry) as geometry, area, name, name_en, name_es, name_fr, name_de, name_ru, name_zh, timestamp
    FROM osm_water_polygons;

CREATE OR REPLACE VIEW layer_water_label AS (
    SELECT osm_id, timestamp, geometry FROM water_label_z10
    UNION
    SELECT osm_id, timestamp, geometry FROM water_label_z11
    UNION
    SELECT osm_id, timestamp, geometry FROM water_label_z12
    UNION
    SELECT osm_id, timestamp, geometry FROM water_label_z13
    UNION
    SELECT osm_id, timestamp, geometry FROM water_label_z14
);

CREATE OR REPLACE FUNCTION changed_tiles_water_label(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_geometries AS (
		    SELECT osm_id, geometry FROM layer_water_label
		    WHERE timestamp = ts
		), changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.tile_x AS x, t.tile_y AS y, t.tile_z AS z
		    FROM changed_geometries AS c
		    INNER JOIN LATERAL overlapping_tiles(c.geometry, 14) AS t ON true
		)

        SELECT c.x, c.y, c.z FROM water_label_z14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 14
		UNION

        SELECT c.x, c.y, c.z FROM water_label_z13 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 13
		UNION

		SELECT c.x, c.y, c.z FROM water_label_z12 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 12
		UNION

		SELECT c.x, c.y, c.z FROM water_label_z11 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 11
		UNION

		SELECT c.x, c.y, c.z FROM water_label_z10 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 10
	);
END;
$$ LANGUAGE plpgsql;


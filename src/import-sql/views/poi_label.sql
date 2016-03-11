CREATE OR REPLACE VIEW poi_label_z14 AS
    SELECT * FROM (
		SELECT geometry, osm_id, ref, website,
			housenumber, street, place, city, country, postcode,
			name, name_en, name_es, name_fr, name_de, name_ru, name_zh,
			type, 0 AS area,
            timestamp
		FROM osm_poi_points
        UNION ALL
		SELECT topoint(geometry) as geometry, osm_id, ref, website,
			housenumber, street, place, city, country, postcode,
			name, name_en, name_es, name_fr, name_de, name_ru, name_zh,
			type, area,
            timestamp
        FROM osm_poi_polygons
    ) AS poi_geoms
    WHERE name <> '';

CREATE OR REPLACE VIEW layer_poi_label AS (
    SELECT osm_id, timestamp, geometry FROM poi_label_z14
);

CREATE OR REPLACE FUNCTION changed_tiles_poi_label(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH changed_geometries AS (
		    SELECT osm_id, geometry FROM layer_poi_label
		    WHERE timestamp = ts
		), changed_tiles AS (
		    SELECT DISTINCT c.osm_id, t.x, t.y, t.z
		    FROM changed_geometries AS c
		    INNER JOIN LATERAL point_to_tiles(
                ST_Y(ST_Transform(c.geometry, 4324)),
                ST_X(ST_Transform(c.geometry, 4324)),
                14
            ) AS t ON true
		)

		SELECT c.x, c.y, c.z FROM poi_label_z14 AS l
		INNER JOIN changed_tiles AS c ON c.osm_id = l.osm_id AND c.z = 14
	);
END;
$$ LANGUAGE plpgsql;



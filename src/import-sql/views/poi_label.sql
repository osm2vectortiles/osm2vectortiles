CREATE OR REPLACE VIEW poi_label_z14 AS
    SELECT * FROM (
		SELECT geometry, osm_id, ref, website,
			housenumber, street, place, city, country, postcode,
			name, name_en, name_es, name_fr, name_de, name_ru, name_zh,
			type, 0 AS area,
            timestamp
		FROM osm_poi_point
        UNION ALL
		SELECT topoint(geometry) as geometry, osm_id, ref, website,
			housenumber, street, place, city, country, postcode,
			name, name_en, name_es, name_fr, name_de, name_ru, name_zh,
			type, area,
            timestamp
        FROM osm_poi_polygon
    ) AS poi_geoms
    WHERE name <> '';

CREATE OR REPLACE VIEW layer_poi_label AS (
    SELECT osm_id, timestamp, geometry FROM poi_label_z14
);

CREATE OR REPLACE FUNCTION changed_tiles_poi_label(ts timestamp)
RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER) AS $$
BEGIN
	RETURN QUERY (
		WITH created_or_updated_osm_ids AS (
	    	SELECT osm_id FROM osm_create 
	    	WHERE (table_name = 'osm_poi_point' OR table_name = 'osm_poi_polygon') AND timestamp = ts
	    	UNION
	    	SELECT osm_id FROM osm_update
	    	WHERE (table_name = 'osm_poi_point' OR table_name = 'osm_poi_polygon') AND timestamp = ts
		), changed_geometries AS (
			SELECT osm_id, timestamp, geometry FROM osm_delete
    		WHERE table_name = 'osm_poi_point' OR table_name = 'osm_poi_polygon'
    		UNION
		    SELECT osm_id, geometry FROM layer_poi_label
		    WHERE timestamp = ts AND osm_id IN (SELECT osm_id FROM created_or_updated_osm_ids)
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



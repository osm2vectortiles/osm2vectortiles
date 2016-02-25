CREATE OR REPLACE VIEW poi_label_z14 AS (
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
    WHERE name <> ''
);

CREATE OR REPLACE VIEW housenum_label AS
    SELECT osm_id, geometry, house_num, timestamp
    FROM osm_housenumbers_points
    UNION ALL
    SELECT osm_id, topoint(geometry) AS geometry, house_num, timestamp
    FROM osm_housenumbers_polygons;
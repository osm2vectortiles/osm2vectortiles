CREATE OR REPLACE VIEW water_label_z10 AS
    SELECT *
    FROM osm_water_polygons
    WHERE area >= 100000000;

CREATE OR REPLACE VIEW water_label_z11 AS
    SELECT *
    FROM osm_water_polygons
    WHERE area >= 40000000;

CREATE OR REPLACE VIEW water_label_z12 AS
    SELECT *
    FROM osm_water_polygons
    WHERE area >= 20000000;

CREATE OR REPLACE VIEW water_label_z13 AS
    SELECT *
    FROM osm_water_polygons
    WHERE area >= 10000000;

CREATE OR REPLACE VIEW water_label_z14 AS
    SELECT *
    FROM osm_water_polygons;

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

CREATE OR REPLACE VIEW road_label_z8toz10 AS
    SELECT *
    FROM osm_roads
    WHERE type IN ('motorway')
      AND ref <> '';

CREATE OR REPLACE VIEW road_label_z11 AS
    SELECT *
    FROM osm_roads
    WHERE type IN ('motorway_link', 'primary', 'primary_link', 'trunk', 'trunk_link', 'secondary', 'secondary_link')
      AND (name <> '' OR ref <> '');

CREATE OR REPLACE VIEW road_label_z12toz13 AS
    SELECT *
    FROM osm_roads
    WHERE type IN ('tertiary', 'tertiary_link', 'residential', 'unclassified', 'living_street', 'pedestrian', 'construction', 'rail', 'monorail', 'narrow_gauge', 'subway', 'tram')
      AND name <> '';

CREATE OR REPLACE VIEW road_label_z14 AS
    SELECT *
    FROM osm_roads
    WHERE type IN ('service', 'track', 'driveway', 'path', 'cycleway', 'ski', 'steps', 'bridleway', 'footway', 'funicular', 'light_rail', 'preserved')
      AND name <> '';

CREATE OR REPLACE VIEW waterway_label_z8toz12 AS
    SELECT *
    FROM osm_water_lines
    WHERE type IN ('river', 'canal');

CREATE OR REPLACE VIEW waterway_label_z13toz14 AS
    SELECT *
    FROM osm_water_lines
    WHERE type IN ('river', 'canal', 'stream', 'stream_intermittent');

CREATE OR REPLACE VIEW housenum_label_z14 AS
    SELECT osm_id, geometry, house_num, timestamp
    FROM osm_housenumbers_points
    UNION ALL
    SELECT osm_id, topoint(geometry) AS geometry, house_num, timestamp
    FROM osm_housenumbers_polygons;
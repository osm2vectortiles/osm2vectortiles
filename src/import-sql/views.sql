CREATE OR REPLACE VIEW tunnel_z12toz14 AS
    SELECT *
    FROM osm_roads
      WHERE is_tunnel;

CREATE OR REPLACE VIEW road_z5to6 AS
    SELECT *
    FROM osm_roads
    WHERE type IN ('motorway', 'trunk');

CREATE OR REPLACE VIEW road_z7 AS
    SELECT *
    FROM osm_roads
    WHERE type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link');

CREATE OR REPLACE VIEW road_z8to10 AS
    SELECT *
    FROM osm_roads
    WHERE type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link', 'secondary', 'secondary_link');

CREATE OR REPLACE VIEW road_z11 AS
    SELECT *
    FROM osm_roads
    WHERE type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link', 'secondary', 'secondary_link', 'tertiary', 'teriary_link');

CREATE OR REPLACE VIEW road_z12 AS
    SELECT *
    FROM osm_roads
    WHERE classify_road(type) IN ('major_rail', 'street')
      AND type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link', 'secondary', 'secondary_link', 'tertiary', 'teriary_link')
      AND NOT is_bridge
      AND NOT is_tunnel;

CREATE OR REPLACE VIEW road_z13 AS
    SELECT *
    FROM osm_roads
    WHERE classify_road(type) IN ('minor_rail', 'street_limited', 'service')
      AND type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link', 'secondary', 'secondary_link', 'tertiary', 'teriary_link')
      AND NOT is_bridge
      AND NOT is_tunnel;

CREATE OR REPLACE VIEW road_z14 AS
    SELECT *
    FROM osm_roads
      WHERE NOT is_bridge
      AND NOT is_tunnel;

CREATE OR REPLACE VIEW bridge_z12to14 AS
    SELECT *
    FROM osm_roads
    WHERE is_bridge;

CREATE OR REPLACE VIEW admin_z2to6 AS
    SELECT *
    FROM osm_admin
    WHERE maritime = 1
    AND admin_level = 2;

CREATE OR REPLACE VIEW admin_z7to14 AS
    SELECT *
    FROM osm_admin
    WHERE ( admin_level = 2 OR admin_level = 4 );

CREATE OR REPLACE VIEW place_label_z4toz5 AS
    SELECT *
    FROM osm_places
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank < 3;

CREATE OR REPLACE VIEW place_label_z6 AS
    SELECT *
    FROM osm_places
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank < 8;

CREATE OR REPLACE VIEW place_label_z7 AS
    SELECT *
    FROM osm_places
    WHERE name <> ''
      AND scalerank IS NOT NULL;

CREATE OR REPLACE VIEW place_label_z8 AS
    SELECT *
    FROM osm_places
    WHERE name <> ''
      AND type IN ('city', 'town');

CREATE OR REPLACE VIEW place_label_z9toz10 AS
    SELECT *
    FROM osm_places
    WHERE name <> ''
      AND type IN ('city', 'town', 'district');

CREATE OR REPLACE VIEW place_label_z11toz12 AS
    SELECT *
    FROM osm_places
    WHERE name <> ''
      AND type IN ('city', 'town', 'district', 'village');

CREATE OR REPLACE VIEW place_label_z13 AS
    SELECT *
    FROM osm_places
    WHERE name <> ''
      AND type IN ('city', 'town', 'district', 'village', 'hamlet', 'suburb','neighbourhood');

CREATE OR REPLACE VIEW place_label_z14 AS
    SELECT *
    FROM osm_places
    WHERE name <> '';

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
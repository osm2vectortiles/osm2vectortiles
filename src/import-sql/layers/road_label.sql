CREATE OR REPLACE VIEW road_label_z8toz10 AS
    SELECT id AS osm_id, type, oneway, ref, layer, z_order,
           is_tunnel, is_bridge, is_ford, construction, tracktype, service, access,
           name, name_fr, name_en, name_de, name_es, name_ru, name_zh, geometry
    FROM osm_road_geometry
    WHERE type IN ('motorway')
      AND ref <> '';

CREATE OR REPLACE VIEW road_label_z11 AS
    SELECT id AS osm_id, type, oneway, ref, layer, z_order,
           is_tunnel, is_bridge, is_ford, construction, tracktype, service, access,
           name, name_fr, name_en, name_de, name_es, name_ru, name_zh, geometry
    FROM osm_road_geometry
    WHERE type IN ('motorway', 'motorway_link', 'primary', 'primary_link', 'trunk', 'trunk_link', 'secondary', 'secondary_link')
      AND (name <> '' OR ref <> '');

CREATE OR REPLACE VIEW road_label_z12toz13 AS
    SELECT id AS osm_id, type, oneway, ref, layer, z_order,
           is_tunnel, is_bridge, is_ford, construction, tracktype, service, access,
           name, name_fr, name_en, name_de, name_es, name_ru, name_zh, geometry
    FROM osm_road_geometry
    WHERE type IN ('motorway', 'motorway_link', 'primary', 'primary_link', 'trunk', 'trunk_link', 'secondary', 'secondary_link',
        'tertiary', 'tertiary_link', 'residential', 'unclassified', 'living_street', 'construction', 'rail', 'monorail', 'narrow_gauge', 'subway', 'tram')
      AND name <> '';

CREATE OR REPLACE VIEW road_label_z14 AS
    SELECT id AS osm_id, type, oneway, ref, layer, z_order,
           is_tunnel, is_bridge, is_ford, construction, tracktype, service, access,
           name, name_fr, name_en, name_de, name_es, name_ru, name_zh, geometry
    FROM osm_road_geometry
    WHERE type IN ('motorway', 'motorway_link', 'primary', 'primary_link', 'trunk', 'trunk_link', 'secondary', 'secondary_link',
        'tertiary', 'tertiary_link', 'residential', 'unclassified', 'living_street', 'construction', 'rail', 'monorail',
        'narrow_gauge', 'subway', 'tram', 'service', 'track', 'driveway', 'path', 'cycleway', 'ski', 'steps', 'bridleway', 'footway', 'funicular', 'light_rail', 'preserved')
      AND name <> '';

CREATE OR REPLACE VIEW road_label_layer AS (
    SELECT osm_id FROM road_label_z8toz10
    UNION
    SELECT osm_id FROM road_label_z11
    UNION
    SELECT osm_id FROM road_label_z12toz13
    UNION
    SELECT osm_id FROM road_label_z14
);

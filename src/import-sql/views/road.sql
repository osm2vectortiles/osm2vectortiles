CREATE OR REPLACE VIEW road_z5toz6 AS
    SELECT *
    FROM osm_roads
    WHERE type IN ('motorway', 'trunk');

CREATE OR REPLACE VIEW road_z7 AS
    SELECT *
    FROM osm_roads
    WHERE type IN ('motorway', 'trunk', 'primary', 'motorway_link', 'primary_link', 'trunk_link');

CREATE OR REPLACE VIEW road_z8toz10 AS
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

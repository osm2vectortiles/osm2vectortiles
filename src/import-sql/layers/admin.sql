CREATE OR REPLACE VIEW admin_z2toz6 AS
    SELECT *
    FROM osm_admin_linestring
    WHERE maritime = 1
      AND admin_level = 2;

CREATE OR REPLACE VIEW admin_z7toz14 AS
    SELECT *
    FROM osm_admin_linestring
    WHERE ( admin_level = 2 OR admin_level = 4 );

CREATE OR REPLACE VIEW admin_layer AS (
    SELECT osm_id, timestamp, geometry FROM admin_z2toz6
    UNION
    SELECT osm_id, timestamp, geometry FROM admin_z7toz14
);

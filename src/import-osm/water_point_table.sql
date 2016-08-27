CREATE OR REPLACE FUNCTION imposm_id_to_osm_id (imposm_id BIGINT, is_polygon BOOLEAN) RETURNS BIGINT AS $$
BEGIN
 RETURN CASE
   WHEN                      (imposm_id >=     0 )                      THEN imposm_id
   WHEN (NOT is_polygon) AND (imposm_id >= -1e17 ) AND (imposm_id < 0 ) THEN abs(imposm_id)
   WHEN (    is_polygon) AND (imposm_id >= -1e17 ) AND (imposm_id < 0 ) THEN abs(imposm_id)
   WHEN (NOT is_polygon) AND (imposm_id <  -1e17 )                    THEN imposm_id +1e17
   WHEN (    is_polygon) AND (imposm_id <  -1e17 )                    THEN imposm_id +1e17
   ELSE 0
 END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

DROP TABLE IF EXISTS osm_water_label CASCADE;
CREATE TABLE osm_water_label AS
SELECT id,
       COALESCE(ll.wkb_geometry, topoint(wp.geometry)) AS geometry,
       timestamp,
       name, name_fr, name_en, name_de,
       name_es, name_ru, name_zh,
       area
FROM osm_water_polygon AS wp
LEFT JOIN custom_lakeline ll ON imposm_id_to_osm_id(wp.id, true) = ll.osm_id;

CREATE INDEX ON osm_water_label USING gist (geometry);
CREATE INDEX ON osm_water_label
USING btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));

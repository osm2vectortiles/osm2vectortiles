CREATE TABLE IF NOT EXISTS osm_delete (
    osm_id bigint,
    geometry geometry,
    timestamp timestamp,
    table_name text
);

CREATE OR REPLACE FUNCTION cleanup_osm_changes() returns VOID
AS $$
DECLARE
    latest_ts timestamp;
BEGIN
    SELECT MAX(timestamp) INTO latest_ts FROM osm_delete;
    DELETE FROM osm_delete WHERE timestamp <> latest_ts;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION track_osm_deletes() returns TRIGGER
AS $$
BEGIN
     IF (TG_OP = 'DELETE') THEN
        INSERT INTO osm_delete(osm_id, geometry, timestamp, table_name)
        VALUES(OLD.osm_id, OLD.geometry, NULL, TG_TABLE_NAME::TEXT);
        RETURN OLD;
     END IF;

     RETURN NULL;
END;
$$ language plpgsql;

-- Place

DROP TRIGGER IF EXISTS osm_place_point_track_changes ON osm_place_point;
CREATE TRIGGER osm_place_point_track_changes
BEFORE DELETE ON osm_place_point
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

DROP TRIGGER IF EXISTS osm_place_polygon_track_changes ON osm_place_polygon;
CREATE TRIGGER osm_place_polygon_track_changes
BEFORE DELETE ON osm_place_polygon
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

-- POI

DROP TRIGGER IF EXISTS osm_poi_point_track_changes ON osm_poi_point;
CREATE TRIGGER osm_poi_point_track_changes
BEFORE DELETE ON osm_poi_point
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

DROP TRIGGER IF EXISTS osm_poi_polygon_track_changes ON osm_poi_polygon;
CREATE TRIGGER osm_poi_polygon_track_changes
BEFORE DELETE ON osm_poi_polygon
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

-- Roads

DROP TRIGGER IF EXISTS osm_road_polygon_track_changes ON osm_road_polygon;
CREATE TRIGGER osm_road_polygon_track_changes
BEFORE DELETE ON osm_road_polygon
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

DROP TRIGGER IF EXISTS osm_road_linestring_track_changes ON osm_road_linestring;
CREATE TRIGGER osm_road_linestring_track_changes
BEFORE DELETE ON osm_road_linestring
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

-- Admin

DROP TRIGGER IF EXISTS osm_admin_linestring_track_changes ON osm_admin_linestring;
CREATE TRIGGER osm_admin_linestring_track_changes
BEFORE DELETE ON osm_admin_linestring
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

-- Water

DROP TRIGGER IF EXISTS osm_water_linestring_track_changes ON osm_water_linestring;
CREATE TRIGGER osm_water_linestring_track_changes
BEFORE DELETE ON osm_water_linestring
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

DROP TRIGGER IF EXISTS osm_water_polygon_track_changes ON osm_water_polygon;
CREATE TRIGGER osm_water_polygon_track_changes
BEFORE DELETE ON osm_water_polygon
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

-- Landuse

DROP TRIGGER IF EXISTS osm_landuse_polygon_track_changes ON osm_landuse_polygon;
CREATE TRIGGER osm_landuse_polygon_track_changes
BEFORE DELETE ON osm_landuse_polygon
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

-- Aeroways

DROP TRIGGER IF EXISTS osm_aero_polygon_track_changes ON osm_aero_polygon;
CREATE TRIGGER osm_aero_polygon_track_changes
BEFORE DELETE ON osm_aero_polygon
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

DROP TRIGGER IF EXISTS osm_aero_linestring_track_changes ON osm_aero_linestring;
CREATE TRIGGER osm_aero_linestring_track_changes
BEFORE DELETE ON osm_aero_linestring
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

-- Buildings

DROP TRIGGER IF EXISTS osm_building_polygon_track_changes ON osm_building_polygon;
CREATE TRIGGER osm_building_polygon_track_changes
BEFORE DELETE ON osm_building_polygon
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

DROP TRIGGER IF EXISTS osm_housenumber_polygon_track_changes ON osm_housenumber_polygon;
CREATE TRIGGER osm_housenumber_polygon_track_changes
BEFORE DELETE ON osm_housenumber_polygon
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

DROP TRIGGER IF EXISTS osm_housenumber_point_track_changes ON osm_housenumber_point;
CREATE TRIGGER osm_housenumber_point_track_changes
BEFORE DELETE ON osm_housenumber_point
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

-- Barrier

DROP TRIGGER IF EXISTS osm_barrier_polygon_track_changes ON osm_barrier_polygon;
CREATE TRIGGER osm_barrier_polygon_track_changes
BEFORE DELETE ON osm_barrier_polygon
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

DROP TRIGGER IF EXISTS osm_barrier_linestring_track_changes ON osm_barrier_linestring;
CREATE TRIGGER osm_barrier_linestring_track_changes
BEFORE DELETE ON osm_barrier_linestring
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

-- Mountain Peaks

DROP TRIGGER IF EXISTS osm_mountain_peak_point_track_changes ON osm_mountain_peak_point;
CREATE TRIGGER osm_mountain_peak_point_track_changes
BEFORE DELETE ON osm_mountain_peak_point
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

-- Airport

DROP TRIGGER IF EXISTS osm_airport_point_track_changes ON osm_airport_point;
CREATE TRIGGER osm_airport_point_track_changes
BEFORE DELETE ON osm_airport_point
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

DROP TRIGGER IF EXISTS osm_airport_polygon_track_changes ON osm_airport_polygon;
CREATE TRIGGER osm_airport_polygon_track_changes
BEFORE DELETE ON osm_airport_polygon
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

-- Rail Station

DROP TRIGGER IF EXISTS osm_rail_station_point_track_changes ON osm_rail_station_point;
CREATE TRIGGER osm_rail_station_point_track_changes
BEFORE DELETE ON osm_rail_station_point
FOR EACH ROW EXECUTE PROCEDURE track_osm_deletes();

CREATE OR REPLACE FUNCTION disable_change_tracking() returns VOID
AS $$
BEGIN
    ALTER TABLE osm_place_point DISABLE TRIGGER USER;
    ALTER TABLE osm_place_polygon DISABLE TRIGGER USER;
    ALTER TABLE osm_poi_point DISABLE TRIGGER USER;
    ALTER TABLE osm_poi_polygon DISABLE TRIGGER USER;
    ALTER TABLE osm_road_polygon DISABLE TRIGGER USER;
    ALTER TABLE osm_road_linestring DISABLE TRIGGER USER;
    ALTER TABLE osm_admin_linestring DISABLE TRIGGER USER;
    ALTER TABLE osm_water_linestring DISABLE TRIGGER USER;
    ALTER TABLE osm_water_polygon DISABLE TRIGGER USER;
    ALTER TABLE osm_landuse_polygon DISABLE TRIGGER USER;
    ALTER TABLE osm_aero_polygon DISABLE TRIGGER USER;
    ALTER TABLE osm_aero_linestring DISABLE TRIGGER USER;
    ALTER TABLE osm_building_polygon DISABLE TRIGGER USER;
    ALTER TABLE osm_housenumber_polygon DISABLE TRIGGER USER;
    ALTER TABLE osm_housenumber_point DISABLE TRIGGER USER;
    ALTER TABLE osm_barrier_polygon DISABLE TRIGGER USER;
    ALTER TABLE osm_barrier_linestring DISABLE TRIGGER USER;
    ALTER TABLE osm_mountain_peak_point DISABLE TRIGGER USER;
    ALTER TABLE osm_airport_point DISABLE TRIGGER USER;
    ALTER TABLE osm_airport_polygon DISABLE TRIGGER USER;
    ALTER TABLE osm_rail_station_point DISABLE TRIGGER USER;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION enable_change_tracking() returns VOID
AS $$
BEGIN
    ALTER TABLE osm_place_point ENABLE TRIGGER USER;
    ALTER TABLE osm_place_polygon ENABLE TRIGGER USER;
    ALTER TABLE osm_poi_point ENABLE TRIGGER USER;
    ALTER TABLE osm_poi_polygon ENABLE TRIGGER USER;
    ALTER TABLE osm_road_polygon ENABLE TRIGGER USER;
    ALTER TABLE osm_road_linestring ENABLE TRIGGER USER;
    ALTER TABLE osm_admin_linestring ENABLE TRIGGER USER;
    ALTER TABLE osm_water_linestring ENABLE TRIGGER USER;
    ALTER TABLE osm_water_polygon ENABLE TRIGGER USER;
    ALTER TABLE osm_landuse_polygon ENABLE TRIGGER USER;
    ALTER TABLE osm_aero_polygon ENABLE TRIGGER USER;
    ALTER TABLE osm_aero_linestring ENABLE TRIGGER USER;
    ALTER TABLE osm_building_polygon ENABLE TRIGGER USER;
    ALTER TABLE osm_housenumber_polygon ENABLE TRIGGER USER;
    ALTER TABLE osm_housenumber_point ENABLE TRIGGER USER;
    ALTER TABLE osm_barrier_polygon ENABLE TRIGGER USER;
    ALTER TABLE osm_barrier_linestring ENABLE TRIGGER USER;
    ALTER TABLE osm_mountain_peak_point ENABLE TRIGGER USER;
    ALTER TABLE osm_airport_point ENABLE TRIGGER USER;
    ALTER TABLE osm_airport_polygon ENABLE TRIGGER USER;
    ALTER TABLE osm_rail_station_point ENABLE TRIGGER USER;
END;
$$ language plpgsql;

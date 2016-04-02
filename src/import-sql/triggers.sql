CREATE TABLE IF NOT EXISTS osm_delete (
    osm_id bigint,
    geometry geometry,
    timestamp timestamp,
    table_name text
);

CREATE TABLE IF NOT EXISTS osm_update (
    osm_id bigint,
    geometry geometry,
    timestamp timestamp,
    table_name text
);

CREATE OR REPLACE FUNCTION cleanup_osm_tracking_tables() returns VOID
AS $$
DECLARE
    latest_ts timestamp;
BEGIN
    SELECT MAX(timestamp) INTO latest_ts FROM osm_delete;
    DELETE FROM osm_delete WHERE timestamp <> latest_ts;
    DELETE FROM osm_update WHERE timestamp <> latest_ts;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION track_osm_delete() returns TRIGGER
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

CREATE OR REPLACE FUNCTION track_osm_update() returns TRIGGER
AS $$
BEGIN
     IF (TG_OP = 'DELETE') THEN
        INSERT INTO osm_update(osm_id, geometry, timestamp, table_name)
        VALUES(OLD.osm_id, OLD.geometry, NULL, TG_TABLE_NAME::TEXT);
        RETURN OLD;
     END IF;

     RETURN NULL;
END;
$$ language plpgsql;

-- Trigger utilities

CREATE OR REPLACE FUNCTION recreate_osm_delete_tracking(table_name text) returns VOID
AS $$
BEGIN
    EXECUTE format(
        'DROP TRIGGER IF EXISTS %I_track_delete ON %I;
        CREATE TRIGGER %I_track_delete
        BEFORE DELETE ON %I
        FOR EACH ROW EXECUTE PROCEDURE track_osm_delete()',
        table_name, table_name, table_name, table_name
    );
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION recreate_osm_update_tracking(table_name text) returns VOID
AS $$
BEGIN
    EXECUTE format(
        'DROP TRIGGER IF EXISTS %I_track_update ON %I;
        CREATE TRIGGER %I_track_update
        BEFORE DELETE ON %I
        FOR EACH ROW EXECUTE PROCEDURE track_osm_update()',
        table_name, table_name, table_name, table_name
    );
END;
$$ language plpgsql;

-- Place

SELECT recreate_osm_delete_tracking('osm_place_point');
SELECT recreate_osm_update_tracking('osm_place_point');

-- POI

SELECT recreate_osm_delete_tracking('osm_poi_point');
SELECT recreate_osm_update_tracking('osm_poi_point');
SELECT recreate_osm_delete_tracking('osm_poi_polygon');
SELECT recreate_osm_update_tracking('osm_poi_polygon');

-- Roads

SELECT recreate_osm_delete_tracking('osm_road_polygon');
SELECT recreate_osm_update_tracking('osm_road_polygon');
SELECT recreate_osm_delete_tracking('osm_road_linestring');
SELECT recreate_osm_update_tracking('osm_road_linestring');

-- Admin

SELECT recreate_osm_delete_tracking('osm_admin_linestring');
SELECT recreate_osm_update_tracking('osm_admin_linestring');

-- Water

SELECT recreate_osm_delete_tracking('osm_water_linestring');
SELECT recreate_osm_update_tracking('osm_water_linestring');
SELECT recreate_osm_delete_tracking('osm_water_polygon');
SELECT recreate_osm_update_tracking('osm_water_polygon');

-- Landuse

SELECT recreate_osm_delete_tracking('osm_landuse_polygon');
SELECT recreate_osm_update_tracking('osm_landuse_polygon');

-- Aeroways

SELECT recreate_osm_delete_tracking('osm_aero_polygon');
SELECT recreate_osm_update_tracking('osm_aero_polygon');
SELECT recreate_osm_delete_tracking('osm_aero_linestring');
SELECT recreate_osm_update_tracking('osm_aero_linestring');

-- Buildings

SELECT recreate_osm_delete_tracking('osm_building_polygon');
SELECT recreate_osm_update_tracking('osm_building_polygon');
SELECT recreate_osm_delete_tracking('osm_housenumber_polygon');
SELECT recreate_osm_update_tracking('osm_housenumber_polygon');
SELECT recreate_osm_delete_tracking('osm_housenumber_point');
SELECT recreate_osm_update_tracking('osm_housenumber_point');

-- Barrier

SELECT recreate_osm_delete_tracking('osm_barrier_polygon');
SELECT recreate_osm_update_tracking('osm_barrier_polygon');
SELECT recreate_osm_delete_tracking('osm_barrier_linestring');
SELECT recreate_osm_update_tracking('osm_barrier_linestring');

-- Mountain Peaks

SELECT recreate_osm_delete_tracking('osm_mountain_peak_point');
SELECT recreate_osm_update_tracking('osm_mountain_peak_point');

-- Timestamp tracking


CREATE OR REPLACE FUNCTION update_timestamp(ts timestamp) returns VOID
AS $$
BEGIN
	UPDATE osm_delete SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_admin_linestring SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_aero_linestring SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_aero_polygon SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_barrier_linestring SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_barrier_polygon SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_building_polygon SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_building_polygon_gen0 SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_housenumber_point SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_housenumber_polygon SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_landuse_polygon SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_landuse_polygon_gen0 SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_landuse_polygon_gen1 SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_place_point SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_poi_point SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_poi_polygon SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_road_linestring SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_road_polygon SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_water_linestring SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_water_polygon SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_water_polygon_gen1 SET timestamp=ts WHERE timestamp IS NULL;
    UPDATE osm_mountain_peak_point SET timestamp=ts WHERE timestamp IS NULL;
END;
$$ language plpgsql;

-- Table Management

CREATE OR REPLACE FUNCTION drop_tables() returns VOID
AS $$
BEGIN
    DROP TABLE osm_delete;
    DROP TABLE osm_admin_linestring;
    DROP TABLE osm_aero_linestring;
    DROP TABLE osm_aero_polygon;
    DROP TABLE osm_barrier_linestring;
    DROP TABLE osm_barrier_polygon;
    DROP TABLE osm_building_polygon;
    DROP TABLE osm_building_polygon_gen0;
    DROP TABLE osm_housenumber_point;
    DROP TABLE osm_housenumber_polygon;
    DROP TABLE osm_landuse_polygon;
    DROP TABLE osm_landuse_polygon_gen0;
    DROP TABLE osm_landuse_polygon_gen1;
    DROP TABLE osm_place_point;
    DROP TABLE osm_poi_point;
    DROP TABLE osm_poi_polygon;
    DROP TABLE osm_road_linestring;
    DROP TABLE osm_road_polygon;
    DROP TABLE osm_water_linestring;
    DROP TABLE osm_water_polygon;
    DROP TABLE osm_water_polygon_gen1;
    DROP TABLE osm_mountain_peak_point;
END;
$$ language plpgsql;

-- Change tracking

CREATE OR REPLACE FUNCTION disable_delete_tracking() returns VOID
AS $$
BEGIN
    ALTER TABLE osm_place_point DISABLE TRIGGER osm_place_point_track_delete;
    ALTER TABLE osm_poi_point DISABLE TRIGGER osm_poi_point_track_delete;
    ALTER TABLE osm_poi_polygon DISABLE TRIGGER osm_poi_polygon_track_delete;
    ALTER TABLE osm_road_polygon DISABLE TRIGGER osm_road_polygon_track_delete;
    ALTER TABLE osm_road_linestring DISABLE TRIGGER osm_road_linestring_track_delete;
    ALTER TABLE osm_admin_linestring DISABLE TRIGGER osm_admin_linestring_track_delete;
    ALTER TABLE osm_water_linestring DISABLE TRIGGER osm_water_linestring_track_delete;
    ALTER TABLE osm_water_polygon DISABLE TRIGGER osm_water_polygon_track_delete;
    ALTER TABLE osm_landuse_polygon DISABLE TRIGGER osm_landuse_polygon_track_delete;
    ALTER TABLE osm_aero_polygon DISABLE TRIGGER osm_aero_polygon_track_delete;
    ALTER TABLE osm_aero_linestring DISABLE TRIGGER osm_aero_linestring_track_delete;
    ALTER TABLE osm_building_polygon DISABLE TRIGGER osm_building_polygon_track_delete;
    ALTER TABLE osm_housenumber_polygon DISABLE TRIGGER osm_housenumber_polygon_track_delete;
    ALTER TABLE osm_housenumber_point DISABLE TRIGGER osm_housenumber_point_track_delete;
    ALTER TABLE osm_barrier_polygon DISABLE TRIGGER osm_barrier_polygon_track_delete;
    ALTER TABLE osm_barrier_linestring DISABLE TRIGGER osm_barrier_linestring_track_delete;
    ALTER TABLE osm_mountain_peak_point DISABLE TRIGGER osm_mountain_peak_point_track_delete;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION enable_delete_tracking() returns VOID
AS $$
BEGIN
    ALTER TABLE osm_place_point ENABLE TRIGGER osm_place_point_track_delete;
    ALTER TABLE osm_poi_point ENABLE TRIGGER osm_poi_point_track_delete;
    ALTER TABLE osm_poi_polygon ENABLE TRIGGER osm_poi_polygon_track_delete;
    ALTER TABLE osm_road_polygon ENABLE TRIGGER osm_road_polygon_track_delete;
    ALTER TABLE osm_road_linestring ENABLE TRIGGER osm_road_linestring_track_delete;
    ALTER TABLE osm_admin_linestring ENABLE TRIGGER osm_admin_linestring_track_delete;
    ALTER TABLE osm_water_linestring ENABLE TRIGGER osm_water_linestring_track_delete;
    ALTER TABLE osm_water_polygon ENABLE TRIGGER osm_water_polygon_track_delete;
    ALTER TABLE osm_landuse_polygon ENABLE TRIGGER osm_landuse_polygon_track_delete;
    ALTER TABLE osm_aero_polygon ENABLE TRIGGER osm_aero_polygon_track_delete;
    ALTER TABLE osm_aero_linestring ENABLE TRIGGER osm_aero_linestring_track_delete;
    ALTER TABLE osm_building_polygon ENABLE TRIGGER osm_building_polygon_track_delete;
    ALTER TABLE osm_housenumber_polygon ENABLE TRIGGER osm_housenumber_polygon_track_delete;
    ALTER TABLE osm_housenumber_point ENABLE TRIGGER osm_housenumber_point_track_delete;
    ALTER TABLE osm_barrier_polygon ENABLE TRIGGER osm_barrier_polygon_track_delete;
    ALTER TABLE osm_barrier_linestring ENABLE TRIGGER osm_barrier_linestring_track_delete;
    ALTER TABLE osm_mountain_peak_point ENABLE TRIGGER osm_mountain_peak_point_track_delete;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION disable_update_tracking() returns VOID
AS $$
BEGIN
    ALTER TABLE osm_place_point DISABLE TRIGGER osm_place_point_track_update;
    ALTER TABLE osm_poi_point DISABLE TRIGGER osm_poi_point_track_update;
    ALTER TABLE osm_poi_polygon DISABLE TRIGGER osm_poi_polygon_track_update;
    ALTER TABLE osm_road_polygon DISABLE TRIGGER osm_road_polygon_track_update;
    ALTER TABLE osm_road_linestring DISABLE TRIGGER osm_road_linestring_track_update;
    ALTER TABLE osm_admin_linestring DISABLE TRIGGER osm_admin_linestring_track_update;
    ALTER TABLE osm_water_linestring DISABLE TRIGGER osm_water_linestring_track_update;
    ALTER TABLE osm_water_polygon DISABLE TRIGGER osm_water_polygon_track_update;
    ALTER TABLE osm_landuse_polygon DISABLE TRIGGER osm_landuse_polygon_track_update;
    ALTER TABLE osm_aero_polygon DISABLE TRIGGER osm_aero_polygon_track_update;
    ALTER TABLE osm_aero_linestring DISABLE TRIGGER osm_aero_linestring_track_update;
    ALTER TABLE osm_building_polygon DISABLE TRIGGER osm_building_polygon_track_update;
    ALTER TABLE osm_housenumber_polygon DISABLE TRIGGER osm_housenumber_polygon_track_update;
    ALTER TABLE osm_housenumber_point DISABLE TRIGGER osm_housenumber_point_track_update;
    ALTER TABLE osm_barrier_polygon DISABLE TRIGGER osm_barrier_polygon_track_update;
    ALTER TABLE osm_barrier_linestring DISABLE TRIGGER osm_barrier_linestring_track_update;
    ALTER TABLE osm_mountain_peak_point DISABLE TRIGGER osm_mountain_peak_point_track_update;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION enable_update_tracking() returns VOID
AS $$
BEGIN
    ALTER TABLE osm_place_point ENABLE TRIGGER osm_place_point_track_update;
    ALTER TABLE osm_poi_point ENABLE TRIGGER osm_poi_point_track_update;
    ALTER TABLE osm_poi_polygon ENABLE TRIGGER osm_poi_polygon_track_update;
    ALTER TABLE osm_road_polygon ENABLE TRIGGER osm_road_polygon_track_update;
    ALTER TABLE osm_road_linestring ENABLE TRIGGER osm_road_linestring_track_update;
    ALTER TABLE osm_admin_linestring ENABLE TRIGGER osm_admin_linestring_track_update;
    ALTER TABLE osm_water_linestring ENABLE TRIGGER osm_water_linestring_track_update;
    ALTER TABLE osm_water_polygon ENABLE TRIGGER osm_water_polygon_track_update;
    ALTER TABLE osm_landuse_polygon ENABLE TRIGGER osm_landuse_polygon_track_update;
    ALTER TABLE osm_aero_polygon ENABLE TRIGGER osm_aero_polygon_track_update;
    ALTER TABLE osm_aero_linestring ENABLE TRIGGER osm_aero_linestring_track_update;
    ALTER TABLE osm_building_polygon ENABLE TRIGGER osm_building_polygon_track_update;
    ALTER TABLE osm_housenumber_polygon ENABLE TRIGGER osm_housenumber_polygon_track_update;
    ALTER TABLE osm_housenumber_point ENABLE TRIGGER osm_housenumber_point_track_update;
    ALTER TABLE osm_barrier_polygon ENABLE TRIGGER osm_barrier_polygon_track_update;
    ALTER TABLE osm_barrier_linestring ENABLE TRIGGER osm_barrier_linestring_track_update;
    ALTER TABLE osm_mountain_peak_point ENABLE TRIGGER osm_mountain_peak_point_track_update;
END;
$$ language plpgsql;

-- Delete and update tracking

CREATE TABLE IF NOT EXISTS osm_delete (
    osm_id bigint,
    geometry geometry,
    timestamp timestamp,
    table_name text
);

CREATE OR REPLACE FUNCTION drop_osm_delete_indizes() returns VOID
AS $$
BEGIN
    DROP INDEX IF EXISTS osm_delete_geom;
    DROP INDEX IF EXISTS osm_delete_geom_geohash;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION create_osm_delete_indizes() returns VOID
AS $$
BEGIN
    CREATE INDEX osm_delete_geom ON osm_delete
    USING gist (geometry);
    CREATE INDEX osm_delete_geom_geohash ON osm_delete
    USING btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)));
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION cleanup_osm_tracking_tables() returns VOID
AS $$
DECLARE
    latest_ts timestamp;
BEGIN
    SELECT MAX(timestamp) INTO latest_ts FROM osm_delete;
    DELETE FROM osm_delete WHERE timestamp <> latest_ts;
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

-- Timestamp tracking

CREATE OR REPLACE FUNCTION update_timestamp(ts timestamp) returns VOID
AS $$
BEGIN
    -- Tracking tables
	UPDATE osm_delete SET timestamp=ts WHERE timestamp IS NULL;

    -- Normal tables
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
	UPDATE osm_place_geometry SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_poi_point SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_poi_polygon SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_road_geometry SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_water_linestring SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_water_polygon SET timestamp=ts WHERE timestamp IS NULL;
	UPDATE osm_water_polygon_gen1 SET timestamp=ts WHERE timestamp IS NULL;
    UPDATE osm_mountain_peak_point SET timestamp=ts WHERE timestamp IS NULL;
    UPDATE osm_rail_station_point SET timestamp=ts WHERE timestamp IS NULL;
    UPDATE osm_airport_point SET timestamp=ts WHERE timestamp IS NULL;
    UPDATE osm_airport_polygon SET timestamp=ts WHERE timestamp IS NULL;
END;
$$ language plpgsql;

-- Table Management

CREATE OR REPLACE FUNCTION drop_tables() returns VOID
AS $$
BEGIN
    -- Tracking tables
    DROP TABLE osm_delete CASCADE;

    -- Normal tables
    DROP TABLE osm_admin_linestring CASCADE;
    DROP TABLE osm_aero_linestring CASCADE;
    DROP TABLE osm_aero_polygon CASCADE;
    DROP TABLE osm_barrier_linestring CASCADE;
    DROP TABLE osm_barrier_polygon CASCADE;
    DROP TABLE osm_building_polygon CASCADE;
    DROP TABLE osm_building_polygon_gen0 CASCADE;
    DROP TABLE osm_housenumber_point CASCADE;
    DROP TABLE osm_housenumber_polygon CASCADE;
    DROP TABLE osm_landuse_polygon CASCADE;
    DROP TABLE osm_landuse_polygon_gen0 CASCADE;
    DROP TABLE osm_landuse_polygon_gen1 CASCADE;
    DROP TABLE osm_place_geometry CASCADE;
    DROP TABLE osm_poi_point CASCADE;
    DROP TABLE osm_poi_polygon CASCADE;
    DROP TABLE osm_road_geometry CASCADE;
    DROP TABLE osm_water_linestring CASCADE;
    DROP TABLE osm_water_polygon CASCADE;
    DROP TABLE osm_water_polygon_gen1 CASCADE;
    DROP TABLE osm_mountain_peak_point CASCADE;
    DROP TABLE osm_rail_station_point CASCADE;
    DROP TABLE osm_airport_point CASCADE;
    DROP TABLE osm_airport_polygon CASCADE;
END;
$$ language plpgsql;

-- Change tracking

CREATE OR REPLACE FUNCTION disable_delete_tracking() returns VOID
AS $$
BEGIN
    ALTER TABLE osm_place_geometry DISABLE TRIGGER USER;
    ALTER TABLE osm_poi_point DISABLE TRIGGER USER;
    ALTER TABLE osm_poi_polygon DISABLE TRIGGER USER;
    ALTER TABLE osm_road_geometry DISABLE TRIGGER USER;
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

CREATE OR REPLACE FUNCTION enable_delete_tracking() returns VOID
AS $$
BEGIN
    ALTER TABLE osm_place_geometry ENABLE TRIGGER USER;
    ALTER TABLE osm_poi_point ENABLE TRIGGER USER;
    ALTER TABLE osm_poi_polygon ENABLE TRIGGER USER;
    ALTER TABLE osm_road_geometry ENABLE TRIGGER USER;
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

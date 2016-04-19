-- Delete and update tracking

CREATE OR REPLACE FUNCTION drop_osm_delete_indizes() returns VOID
AS $$
BEGIN
    DROP INDEX IF EXISTS osm_delete_geom;
    DROP INDEX IF EXISTS osm_delete_geom_geohash;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION create_osm_delete_index(table_name TEXT) returns VOID
AS $$
BEGIN
    EXECUTE 'CREATE INDEX osm_delete_geom ON $1 USING gist (geometry)'
    USING table_name;
    EXECUTE 'CREATE INDEX osm_delete_geom_geohash ON $1
    USING btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)))'
    USING table_name;
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
        EXECUTE 'INSERT INTO $1(osm_id, geometry, timestamp)
                 VALUES(OLD.osm_id, OLD.geometry, NULL)
                ' USING TG_TABLE_NAME::TEXT || '_delete';
        RETURN OLD;
     END IF;

     RETURN NULL;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION create_delete_table(table_name TEXT) returns VOID
AS $$
BEGIN
    EXECUTE 'CREATE TABLE IF NOT EXISTS $1 (
        osm_id bigint,
        geometry geometry,
        timestamp timestamp
    )' USING table_name;
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

CREATE OR REPLACE FUNCTION modify_delete_tracking(table_name TEXT, enable BOOLEAN)
RETURNS VOID AS $$
BEGIN
    EXECUTE format('ALTER TABLE %I %s TRIGGER USER', table_name,
                   CASE WHEN enable THEN 'ENABLE' ELSE 'DISABLE' END);
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION enable_delete_tracking() RETURNS VOID AS $$
BEGIN
    SELECT modify_delete_tracking(table_name, true)
    FROM osm_tables;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION disable_delete_tracking() RETURNS VOID AS $$
BEGIN
    SELECT modify_delete_tracking(table_name, false)
    FROM osm_tables;
END;
$$ language plpgsql;

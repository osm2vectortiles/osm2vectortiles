CREATE OR REPLACE FUNCTION drop_osm_delete_index(table_name TEXT) returns VOID
AS $$
BEGIN
    EXECUTE format('DROP INDEX IF EXISTS %I', table_name || '_geom');
    EXECUTE format('DROP INDEX IF EXISTS %I', table_name || '_geom_geohash');
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION drop_osm_delete_indizes() RETURNS VOID AS $$
BEGIN
    PERFORM drop_osm_delete_index(table_name)
    FROM osm_tables_delete;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION create_osm_delete_index(table_name TEXT) returns VOID
AS $$
BEGIN
    EXECUTE format('CREATE INDEX %I ON %I USING gist (geometry)', table_name || '_geom', table_name);
    EXECUTE format('CREATE INDEX %I ON %I
    USING btree (st_geohash(st_transform(st_setsrid(box2d(geometry)::geometry, 3857), 4326)))',
    table_name || '_geom_geohash', table_name);
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION cleanup_osm_tracking_tables() returns VOID
AS $$
DECLARE
    latest_ts timestamp;
    t osm_tables%ROWTYPE;
BEGIN
    SELECT MAX(timestamp) INTO latest_ts FROM osm_timestamps;
    FOR t IN SELECT * FROM osm_tables_delete LOOP
        EXECUTE format('DELETE FROM %I WHERE timestamp <> $1', t.table_name) USING latest_ts;
    END LOOP;
END;
$$ language plpgsql;

-- TODO: Perhaps a dynamic trigger is really slow
-- if it is a performance problem we should generate static
-- triggers for each table
CREATE OR REPLACE FUNCTION track_osm_delete() returns TRIGGER
AS $$
BEGIN
     IF (TG_OP = 'DELETE') THEN
        EXECUTE format('
            INSERT INTO %I(id, geometry)
            VALUES($1, $2)', TG_TABLE_NAME::TEXT || '_delete')
            USING OLD.id, OLD.geometry;
        RETURN OLD;
     END IF;

     RETURN NULL;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION create_delete_table(table_name TEXT) returns VOID
AS $$
BEGIN
    EXECUTE format('CREATE TABLE IF NOT EXISTS %I (
        id bigint,
        geometry geometry,
        timestamp timestamp
    )', table_name);
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
    PERFORM modify_delete_tracking(table_name, true)
    FROM osm_tables;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION disable_delete_tracking() RETURNS VOID AS $$
BEGIN
    PERFORM modify_delete_tracking(table_name, false)
    FROM osm_tables;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION create_osm_delete_indizes() RETURNS VOID AS $$
BEGIN
    PERFORM create_osm_delete_index(table_name)
    FROM osm_tables_delete;
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION create_delete_tables() RETURNS VOID AS $$
BEGIN
    PERFORM create_delete_table(table_name)
    FROM osm_tables_delete;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION create_tracking_triggers() RETURNS VOID AS $$
BEGIN
    PERFORM recreate_osm_delete_tracking(table_name)
    FROM osm_tables;
END;
$$ language plpgsql;

CREATE OR REPLACE VIEW osm_tables_delete AS (
    SELECT table_name || '_delete' AS table_name, buffer_size, min_zoom, max_zoom
    FROM osm_tables
);

CREATE OR REPLACE FUNCTION update_timestamp(ts timestamp) RETURNS VOID AS $$
DECLARE t osm_tables%ROWTYPE;
BEGIN
    FOR t IN SELECT * FROM osm_tables LOOP
        EXECUTE format('UPDATE %I SET timestamp=$1 WHERE timestamp IS NULL;',
                       t.table_name) USING ts;
    END LOOP;
END;
$$ language plpgsql;

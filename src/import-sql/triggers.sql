CREATE TABLE IF NOT EXISTS osm_delete (
	osm_id bigint,
    geometry geometry,
    timestamp timestamp,
    table_name text,
    sha1 bytea
    --PRIMARY KEY (osm_id, geometry, timestamp, table_name, sha1)
);

CREATE TABLE IF NOT EXISTS osm_create (
    osm_id bigint,
    timestamp timestamp,
    table_name text,
    sha1 bytea
    --PRIMARY KEY (osm_id, geometry, timestamp, table_name, sha1)
);

CREATE TABLE IF NOT EXISTS osm_modify (
    osm_id bigint,
    timestamp timestamp,
    table_name text,
    sha1 bytea
    --PRIMARY KEY (osm_id, geometry, timestamp, table_name, sha1)
);

CREATE OR REPLACE FUNCTION cleanup_osm_changes() returns VOID
AS $$
DECLARE
    latest_ts timestamp;
BEGIN
    SELECT MAX(timestamp) INTO latest_ts FROM osm_modify;
    DELETE FROM osm_modify WHERE timestamp <> latest_ts;

    SELECT MAX(timestamp) INTO latest_ts FROM osm_delete;
    DELETE FROM osm_delete WHERE timestamp <> latest_ts;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION track_osm_changes() returns TRIGGER
AS $$
DECLARE
    row_data text;
    original_id bigint;
    deleted_count integer;
    duplicate_count integer;
    row_hash bytea;
BEGIN
     IF (TG_OP = 'DELETE') THEN
        OLD.timestamp := NULL;
        OLD.id := NULL;
        row_data = ROW(OLD.*);
        row_hash := digest(row_data, 'sha1');

		INSERT INTO osm_delete(osm_id, geometry, timestamp, table_name, sha1)
        VALUES(OLD.osm_id, OLD.geometry, NULL, TG_TABLE_NAME::TEXT, row_hash);
		RETURN OLD;
     END IF;

     IF (TG_OP = 'INSERT') THEN        
        original_id := NEW.id;
        NEW.id := NULL;
        row_data := ROW(NEW.*);
        row_hash := digest(row_data, 'sha1');
        NEW.id := original_id;

        WITH deleted AS (
            DELETE FROM osm_delete
            WHERE osm_id = NEW.osm_id
              AND timestamp IS NULL
              AND table_name = TG_TABLE_NAME::TEXT   
              RETURNING *
        ) SELECT count(*) INTO deleted_count;

        IF (deleted_count >= 1) THEN       
            SELECT COUNT(*) INTO duplicate_count
            FROM  osm_modify
            WHERE osm_id = NEW.osm_id
              AND table_name = TG_TABLE_NAME::TEXT   
              AND sha1 = row_hash;

            IF (duplicate_count = 0) THEN
                INSERT INTO osm_modify(osm_id, timestamp, table_name, sha1)
                VALUES(NEW.osm_id, NULL, TG_TABLE_NAME::TEXT, row_hash);
            END IF;
        ELSE
            INSERT INTO osm_create(osm_id, timestamp, table_name, sha1)
            VALUES(NEW.osm_id, NULL, TG_TABLE_NAME::TEXT, row_hash);
        END IF;

		RETURN NEW;
     END IF;

     RETURN NULL;
END;
$$ language plpgsql;

DROP TRIGGER IF EXISTS osm_poi_points_track_changes ON osm_poi_point;
CREATE TRIGGER osm_poi_points_track_changes BEFORE INSERT OR DELETE
    ON osm_poi_point FOR EACH ROW EXECUTE PROCEDURE track_osm_changes();

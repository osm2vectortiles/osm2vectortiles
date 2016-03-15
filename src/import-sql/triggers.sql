DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'change') THEN
		CREATE TYPE change AS ENUM ('add', 'mod', 'del');
    END IF;
END $$;


CREATE TABLE IF NOT EXISTS osm_changes (
	osm_id bigint,
    change change,
 	timestamp timestamp
);

CREATE OR REPLACE FUNCTION track_osm_changes() returns TRIGGER
AS $$
DECLARE
	deleted_count integer;
BEGIN
     IF (TG_OP = 'DELETE') THEN
		INSERT INTO osm_changes(osm_id, change, timestamp)  
        VALUES(OLD.osm_id, 'del', NULL);
		RETURN NULL;
     END IF;

     IF (TG_OP = 'INSERT') THEN	
		WITH deleted AS (
			DELETE FROM osm_changes
     		WHERE osm_id = NEW.osm_id
     		  AND timestamp IS NULL
     		  AND change = 'del'
			RETURNING *
		) SELECT count(*) INTO deleted_count;

		IF (deleted_count >= 1) THEN
			INSERT INTO osm_changes(osm_id, change, timestamp)  
	        VALUES(NEW.osm_id, 'mod', NULL);
	    ELSE
			INSERT INTO osm_changes(osm_id, change, timestamp)  
	        VALUES(NEW.osm_id, 'add', NULL);
		END IF;

		RETURN NEW;
     END IF;

     RETURN NULL;
END;
$$ language plpgsql;

DROP TRIGGER IF EXISTS osm_poi_points_track_changes ON osm_poi_point;
CREATE TRIGGER osm_poi_points_track_changes BEFORE INSERT OR DELETE
    ON osm_poi_point FOR EACH ROW EXECUTE PROCEDURE track_osm_changes();

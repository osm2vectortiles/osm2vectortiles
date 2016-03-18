CREATE OR REPLACE FUNCTION osm_poi_point_del_trigger()
  RETURNS trigger AS
$BODY$
BEGIN
     IF (TG_OP = 'DELETE') THEN
        UPDATE osm_poi_point SET timestamp = NULL;
      END IF;
END ;
$BODY$ language plpgsql;
;

CREATE RULE prevent_delete AS ON DELETE TO osm_poi_point DO INSTEAD NOTHING;
DROP TRIGGER IF EXISTS delete_trigger_poi_point ON osm_poi_point; 
CREATE TRIGGER delete_trigger_poi_point
  BEFORE DELETE
  ON osm_poi_point
  FOR EACH ROW
  EXECUTE PROCEDURE osm_poi_point_del_trigger();
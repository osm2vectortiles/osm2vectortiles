CREATE OR REPLACE FUNCTION count_osmid(tablelist TEXT[]) RETURNS  bigint AS $$
DECLARE
  i int8 := 0;
  feature_count bigint;
  code text := '';
  table_name text;
  fullcode text;
  numpars int := array_length(tablelist, 1);
BEGIN
  IF numpars = 0 THEN
    fullcode = ' select null ';
  ELSIF numpars = 1 THEN
     fullcode = ' select count( distinct osm_id ) as alluid from ' || tablelist[1];
  ELSE
     FOREACH table_name IN ARRAY tablelist
     LOOP
        IF i = 0 THEN
           code = code || '       select osm_id from ' || table_name;
        ELSE
           code = code || ' union select osm_id from ' || table_name;
        END IF ;
        i = i + 1;
     END LOOP;
     fullcode = ' select count( distinct osm_id ) as  alluid   from  (' || code || ')  as sq';
  END IF;
  EXECUTE fullcode INTO feature_count;
  RETURN feature_count;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION compare_layer_feature_count(id text, iosmlist TEXT[], ilayerlist TEXT[])
RETURNS TABLE (
   tid text,
   db_features bigint,
   vt_features bigint,
   tables TEXT[],
   layers TEXT[]
) AS $$
BEGIN
  RETURN QUERY
  SELECT id as tid,
         count_osmid(iosmlist) as db_features,
         count_osmid(ilayerlist) as vt_features,
         iosmlist as tables,
         ilayerlist as layers;
END;
$$ LANGUAGE plpgsql;

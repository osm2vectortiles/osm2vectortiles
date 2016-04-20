

-- analyse osm2vectortiles   imposm3mapped  vs.  used   osm_id-s
-- draft code
-- current know limitation
--    ﻿current  imposm3 mapping osm_id is not uniq :  "type_mappings" without "use_single_id_space": true, 


CREATE OR REPLACE FUNCTION count_osmid( tablelist TEXT[] )  RETURNS  bigint AS $$
DECLARE
  i int8    := 0;
  c bigint  ;
  code text ;
  tr   text ;
  t    text ;
  fullcode text ;
  numpars int;
BEGIN
  numpars = array_length( tablelist ,1 ) ;
  code = '';
  IF  numpars = 0 THEN
    fullcode = ' select null ';
  ELSIF numpars = 1 THEN
     fullcode=  ' select count( distinct osm_id ) as  alluid from ' || tablelist[1] ;
  ELSE
     FOREACH t IN ARRAY tablelist
     LOOP
        IF  i = 0 THEN 
           tr = '       select osm_id from '|| t  ;
        ELSE
           tr = ' union select osm_id from '|| t ;
        END IF ;
        code = code || tr ;     
        i  = i +1 ;
     END LOOP;
     fullcode=  ' select count( distinct osm_id ) as  alluid   from  (' || code || ')  as sq'; 
  END IF ;
  EXECUTE fullcode INTO c ;
  RETURN c;
END;
$$ LANGUAGE plpgsql;

-- DROP FUNCTION checkvlayer(text,text[],text[])
CREATE OR REPLACE FUNCTION checkvlayer( id text , iosmlist TEXT[]  ,  ilayerlist TEXT[] )
RETURNS TABLE (
                                     tid       text
                                    ,allrec    bigint    
                                    ,usedrec   bigint 
                                    ,osmlist   TEXT[]  
                                    ,layerlist TEXT[]  ) 
                                     AS $$
DECLARE
BEGIN

  RETURN QUERY 
  SELECT id as tid
       , count_osmid( iosmlist   ) as allrec  
       , count_osmid( ilayerlist ) as usedrec 
       , iosmlist   as osmlist
       , ilayerlist as layerlist
      ;
END;
$$ LANGUAGE plpgsql;



WITH vlayers AS
(
      select * from checkvlayer('osm_admin_linestring'   , array['osm_admin_linestring']      ,array['admin_layer']    )
union select * from checkvlayer('osm_aero_*'             , array['osm_aero_linestring'
                                                                ,'osm_aero_polygon']          ,array['aeroway_layer']  )
union select * from checkvlayer('osm_airport_*'          , array['osm_airport_point'
                                                                ,'osm_airport_polygon']       ,array['airport_label_layer'] )
union select * from checkvlayer('osm_barrier_*'          , array['osm_barrier_linestring'
                                                                ,'osm_barrier_polygon']       ,array['barrier_line_layer']) 
union select * from checkvlayer('osm_building_*'         , array['osm_building_polygon_gen0'
                                                                ,'osm_building_polygon']      ,array['building_layer'])
union select * from checkvlayer('osm_housenumber_*'      , array['osm_housenumber_point'
                                                                ,'osm_housenumber_polygon']   ,array['housenum_label_layer'])
union select * from checkvlayer('osm_landuse_*'          , array['osm_landuse_polygon'
                                                                ,'osm_landuse_polygon_gen0'
                                                                ,'osm_landuse_polygon_gen1']  ,array['landuse_overlay_layer', 'landuse_layer'])
union select * from checkvlayer('osm_mountain_peak_point', array['osm_mountain_peak_point']   ,array['mountain_peak_label_layer'])
union select * from checkvlayer('osm_place_*'            , array['osm_place_geometry']        ,array['place_label_layer'])   
union select * from checkvlayer('osm_poi_*'              , array['osm_poi_point'
                                                                ,'osm_poi_polygon']           ,array['poi_label_layer']) 
union select * from checkvlayer('osm_rail_station_point' , array['osm_rail_station_point']    ,array['rail_station_label_layer'])
union select * from checkvlayer('osm_road_geometry'      , array['osm_road_geometry']         ,array['road_layer', 'road_label_layer'])
union select * from checkvlayer('osm_water_polygon_*'    , array['osm_water_polygon_gen1'         
                                                                ,'osm_water_polygon']         ,array['water_layer','water_label_layer'])
union select * from checkvlayer('osm_water_linestring'   , array['osm_water_linestring']      ,array['waterway_layer','waterway_label_layer'])
)
SELECT
      *
    , round ( ( usedrec::numeric*100) / allrec::numeric ,2 )  as percent
   from  vlayers 
   order by tid
;


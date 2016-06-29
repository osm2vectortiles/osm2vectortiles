
-- postgis version info
          SELECT 'ReportName   :' as id, 'O2V-QA-R001 Analyze Geometry tables '::text  as ver     
UNION ALL SELECT 'ReportVersion:' as id, 'v0.0.1/2016-jun-29'::text    as ver
UNION ALL SELECT 'RunTime      :' as id, Now()::text                   as ver
UNION ALL SELECT 'postgis      :' as id, PostGIS_full_version()::text  as ver
UNION ALL SELECT 'postgresql   :' as id, version()::text               as ver
;


--    DROP FUNCTION o2v_analyze_area_layer(text,regclass,bool) ;
CREATE OR REPLACE FUNCTION o2v_analyze_area_layer( grp text, _tbl regclass ,typefield bool  DEFAULT true ) 
RETURNS TABLE (
    tgrp         text
   ,tablename    text
   ,count_rec    numeric  
   ,uniq_id      numeric
   ,uniq_type    numeric
   ,sum_area     numeric
   ,avg_area     numeric
   ,min_area     numeric
   ,max_area     numeric
   ,sum_length   numeric   
   ,avg_length   numeric
   ,min_length   numeric
   ,max_length   numeric   
   ,max_numgeom  numeric
   ,avg_numgeom  numeric
 
   ,n_point            numeric
   ,n_linestring       numeric
   ,n_multilinestring  numeric
   ,n_polygon          numeric
   ,n_multipolygon     numeric 
   ,n_other            numeric

   ,n_polyarea_l10m2   numeric
   ,n_polyarea_l100m2  numeric
   ,n_polyarea_l1000m2 numeric

   ,n_linelen_l1m      numeric
   ,n_linelen_l10m     numeric
   ,n_linelen_l100m    numeric
   ,n_linelen_l1000m   numeric
          
   ,id_md5_1     numeric
   ,id_md5_2     numeric
   ,id_md5_3     numeric
   ,id_md5_4     numeric     
) AS $func$
DECLARE
    tid text;
    type_qstr text;
BEGIN

IF SUBSTR( _tbl::text,1,3 ) = 'osm' 
  THEN  tid='id';
  ELSE  tid='osm_id';
END IF;

IF typefield 
 THEN  type_qstr=' count( distinct type)::numeric ';    
 ELSE  type_qstr=' 0::numeric';
END IF;

RETURN QUERY EXECUTE format('
          SELECT  
            %5$L::text                                            AS tgrp 
          , %1$s::text                                            AS tablename
          , count( *            )::numeric                        AS count_rec  
          , count( distinct %2$s)::numeric                        AS uniq_id
          , %6$s                                                  AS uniq_type
          , round(sum(st_area(  geometry)::numeric),0)::numeric   AS sum_area
          , round(avg(st_area(  geometry)::numeric),3)::numeric   AS avg_area            
          , round(min(st_area(  geometry)::numeric),8)::numeric   AS min_area           
          , round(max(st_area(  geometry)::numeric),0)::numeric   AS max_area
         
          , round(sum(st_length(geometry)::numeric),0)::numeric   AS sum_length          
          , round(avg(st_length(geometry)::numeric),3)::numeric   AS avg_length            
          , round(min(st_length(geometry)::numeric),8)::numeric   AS min_length           
          , round(max(st_length(geometry)::numeric),0)::numeric   AS max_length          
          ,       max( ST_NumGeometries( geometry )   )::numeric  AS max_numgeom 
          , round(avg( ST_NumGeometries( geometry )),8)::numeric  AS avg_numgeom

          , sum( (ST_GeometryType(geometry)=$$ST_Point$$          )::int )::numeric AS n_point 
          , sum( (ST_GeometryType(geometry)=$$ST_LineString$$     )::int )::numeric AS n_linestring
          , sum( (ST_GeometryType(geometry)=$$ST_MultiLineString$$)::int )::numeric AS n_multilinestring
          , sum( (ST_GeometryType(geometry)=$$ST_Polygon$$        )::int )::numeric AS n_polygon
          , sum( (ST_GeometryType(geometry)=$$ST_MultiPolygon$$   )::int )::numeric AS n_multipolygon
          , sum( (ST_GeometryType(geometry) not in ( $$ST_Point$$ 
                                                   , $$ST_LineString$$
                                                   , $$ST_MultiLineString$$
                                                   , $$ST_Polygon$$
                                                   , $$ST_MultiPolygon$$)  )::int )::numeric AS n_other

          , sum( (ST_GeometryType(geometry) in ($$ST_Polygon$$,$$ST_MultiPolygon$$)  )::int *  (st_area(geometry)< 10  )::int )::numeric AS n_polyarea_l10m2
          , sum( (ST_GeometryType(geometry) in ($$ST_Polygon$$,$$ST_MultiPolygon$$)  )::int *  (st_area(geometry)< 100 )::int )::numeric AS n_polyarea_l100m2
          , sum( (ST_GeometryType(geometry) in ($$ST_Polygon$$,$$ST_MultiPolygon$$)  )::int *  (st_area(geometry)< 1000)::int )::numeric AS n_polyarea_l1000m2

          , sum( (ST_GeometryType(geometry) in ($$ST_LineString$$,$$ST_MultiLineString$$)  )::int *  (st_length(geometry)< 1   )::int )::numeric AS n_linelen_l1m
          , sum( (ST_GeometryType(geometry) in ($$ST_LineString$$,$$ST_MultiLineString$$)  )::int *  (st_length(geometry)< 10  )::int )::numeric AS n_linelen_l10m
          , sum( (ST_GeometryType(geometry) in ($$ST_LineString$$,$$ST_MultiLineString$$)  )::int *  (st_length(geometry)< 100 )::int )::numeric AS n_linelen_l100m
          , sum( (ST_GeometryType(geometry) in ($$ST_LineString$$,$$ST_MultiLineString$$)  )::int *  (st_length(geometry)< 1000)::int )::numeric AS n_linelen_l1000m
          
          , sum(( %3$L || substring( md5( %2$s::text) ,  1, 8))::bit(32)::bigint) AS id_md5_1
          , sum(( %3$L || substring( md5( %2$s::text) ,  9, 8))::bit(32)::bigint) AS id_md5_2
          , sum(( %3$L || substring( md5( %2$s::text) , 17, 8))::bit(32)::bigint) AS id_md5_3
          , sum(( %3$L || substring( md5( %2$s::text) , 25, 8))::bit(32)::bigint) AS id_md5_4                    
          FROM %4$s '   , quote_literal(_tbl::text), tid, 'x', _tbl , grp , type_qstr  )
;
END
$func$ LANGUAGE plpgsql;


--  query --

          SELECT * from o2v_analyze_area_layer('road','osm_road_geometry', true )
UNION ALL SELECT * from o2v_analyze_area_layer('road','road_z5',     true )
UNION ALL SELECT * from o2v_analyze_area_layer('road','road_z6toz7', true )
UNION ALL SELECT * from o2v_analyze_area_layer('road','road_z8toz9', true )
UNION ALL SELECT * from o2v_analyze_area_layer('road','road_z10',    true )
UNION ALL SELECT * from o2v_analyze_area_layer('road','road_z11',    true )
UNION ALL SELECT * from o2v_analyze_area_layer('road','road_z12',    true )
UNION ALL SELECT * from o2v_analyze_area_layer('road','road_z13',    true )
UNION ALL SELECT * from o2v_analyze_area_layer('road','road_z14',    true )
UNION ALL SELECT * from o2v_analyze_area_layer('barrier','osm_barrier_polygon', true )
UNION ALL SELECT * from o2v_analyze_area_layer('barrier','barrier_line_z14',    true )
UNION ALL SELECT * from o2v_analyze_area_layer('building','building_z13',       false )
UNION ALL SELECT * from o2v_analyze_area_layer('building','building_z14',       false )
UNION ALL SELECT * from o2v_analyze_area_layer('water','water_z0',       false )
UNION ALL SELECT * from o2v_analyze_area_layer('water','water_z1',       false )
UNION ALL SELECT * from o2v_analyze_area_layer('water','water_z2toz3',   false )
UNION ALL SELECT * from o2v_analyze_area_layer('water','water_z4',       false )
UNION ALL SELECT * from o2v_analyze_area_layer('water','water_z5toz7',   false )
UNION ALL SELECT * from o2v_analyze_area_layer('water','water_z8toz10',  false )
UNION ALL SELECT * from o2v_analyze_area_layer('water','water_z11toz12', false )
UNION ALL SELECT * from o2v_analyze_area_layer('water','water_z13toz14', false )
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'osm_landuse_polygon')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'osm_landuse_polygon_gen0')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'osm_landuse_polygon_gen1')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_z5toz6')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_z7toz8')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_z9')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_z10')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_z11')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_z12')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_z13toz14')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_overlay_z5')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_overlay_z6')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_overlay_z7')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_overlay_z8')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_overlay_z9')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_overlay_z10')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_overlay_z11toz12')
UNION ALL SELECT * from o2v_analyze_area_layer('land' ,'landuse_overlay_z13toz14')
;


     
            

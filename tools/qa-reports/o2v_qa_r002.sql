

-- postgis version info
          SELECT 'ReportName   :' as id, 'O2V-QA-R002 System info - Geometry tables & indexes'::text  as ver     
UNION ALL SELECT 'ReportVersion:' as id, 'v0.0.1/2016-jun-29'::text    as ver
UNION ALL SELECT 'RunTime      :' as id, Now()::text                   as ver
UNION ALL SELECT 'postgis      :' as id, PostGIS_full_version()::text  as ver
UNION ALL SELECT 'postgresql   :' as id, version()::text               as ver
;


--  Tables  and Views ...


WITH o2v_vars AS  (
      SELECT  table_name, column_name, udt_name  
      FROM information_schema.columns 
      WHERE table_schema = 'public'  
            AND table_name NOT IN ('geography_columns','geometry_columns','raster_columns'
                                  ,'raster_overviews' ,'spatial_ref_sys' )
      ORDER BY table_name, column_name
     )
    ,o2v_geom AS (
      SELECT  table_name, column_name as geomvar_name 
      FROM    o2v_vars
      WHERE   udt_name='geometry'
     )
    ,o2v_type AS (
      SELECT table_name, column_name AS typevar_name
      FROM    o2v_vars
      WHERE column_name='type'
    )
    ,o2v_id AS (
      SELECT table_name, column_name AS idvar_name
      FROM    o2v_vars
      WHERE column_name IN ('id','osm_id','ogc_fid','gid')
    )
    ,o2v_tables AS  (
      SELECT  table_name, table_type  
      FROM information_schema.tables 
      WHERE table_schema = 'public'
     )
    ,o2v_table_columns AS  (
      SELECT  table_name, count(*) AS n_columns 
      FROM o2v_vars
      GROUP BY table_name
      ORDER BY table_name      
     )
     ,o2v_indexes AS  (
      SELECT  relname as table_name, count(*) AS n_index 
      FROM pg_stat_all_indexes
      WHERE schemaname = 'public' 
            AND relname NOT IN ('geography_columns','geometry_columns','raster_columns'
                               ,'raster_overviews' ,'spatial_ref_sys' )
      GROUP BY relname
      ORDER BY relname      
     )         
 SELECT 
    o2v_geom.table_name
   ,o2v_tables.table_type
   ,o2v_table_columns.n_columns  
   ,o2v_geom.geomvar_name
   ,o2v_type.typevar_name
   ,o2v_id.idvar_name
   ,o2v_indexes.n_index 
   ,pg_size_pretty( pg_total_relation_size(o2v_geom.table_name))  AS full_total_size
   ,pg_total_relation_size(o2v_geom.table_name)                   AS total_relation_size
   ,pg_table_size(o2v_geom.table_name)                            AS table_size
   ,pg_indexes_size(o2v_geom.table_name)                          AS indexes_size
 FROM o2v_geom
 LEFT JOIN o2v_tables        ON  o2v_geom.table_name = o2v_tables.table_name
 LEFT JOIN o2v_type          ON  o2v_geom.table_name = o2v_type.table_name
 LEFT JOIN o2v_id            ON  o2v_geom.table_name = o2v_id.table_name
 LEFT JOIN o2v_table_columns ON  o2v_geom.table_name = o2v_table_columns.table_name 
 LEFT JOIN o2v_indexes       ON  o2v_geom.table_name = o2v_indexes.table_name  
 ORDER BY table_name 
;



--  Indexes ...
SELECT relname, indexrelname, idx_scan, idx_tup_read,idx_tup_fetch, pg_size_pretty(pg_relation_size(indexrelname::text))
    FROM pg_stat_all_indexes 
    WHERE schemaname = 'public' 
          AND relname NOT IN ('geography_columns','geometry_columns','raster_columns'
                             ,'raster_overviews' ,'spatial_ref_sys' )
    ORDER BY relname, indexrelname 
;



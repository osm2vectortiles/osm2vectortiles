
-- postgis version info
          SELECT 'ReportName   :' as id, 'O2V-QA-R000 Environment  '::text  as ver     
UNION ALL SELECT 'ReportVersion:' as id, 'v0.0.1/2016-jun-29'::text    as ver
UNION ALL SELECT 'RunTime      :' as id, Now()::text                   as ver
UNION ALL SELECT 'postgis      :' as id, PostGIS_full_version()::text  as ver
UNION ALL SELECT 'postgresql   :' as id, version()::text               as ver
;

-- orher part is generated from bash ... 
            

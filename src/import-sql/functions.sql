-- OSM ID transformations

-- specification : https://www.mapbox.com/vector-tiles/mapbox-streets-v7/
-- osm_ids :  imposm3 with use_single_id_space:true
CREATE OR REPLACE FUNCTION osm_ids2mbid (osm_ids BIGINT, is_polygon bool ) RETURNS BIGINT AS $$
BEGIN
 RETURN CASE
   WHEN                      (osm_ids >=     0 )                    THEN (      osm_ids         * 10)       -- +0 point
   WHEN (NOT is_polygon) AND (osm_ids >= -1e17 ) AND (osm_ids < 0 ) THEN ( (abs(osm_ids)      ) * 10) + 1   -- +1 way linestring
   WHEN (    is_polygon) AND (osm_ids >= -1e17 ) AND (osm_ids < 0 ) THEN ( (abs(osm_ids)      ) * 10) + 2   -- +2 way poly
   WHEN (NOT is_polygon) AND (osm_ids <  -1e17 )                    THEN ( (abs(osm_ids) -1e17) * 10) + 3   -- +3 relations linestring
   WHEN (    is_polygon) AND (osm_ids <  -1e17 )                    THEN ( (abs(osm_ids) -1e17) * 10) + 4   -- +4 relations poly
   ELSE 0
 END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;


CREATE OR REPLACE FUNCTION is_polygon( geom geometry) RETURNS bool AS $$
BEGIN
    RETURN ST_GeometryType(geom) IN ('ST_Polygon', 'ST_MultiPolygon');
END;
$$ LANGUAGE plpgsql IMMUTABLE;


/*
-- example call for osm_ids2mbid
select id
      ,osm_ids2mbid ( id,   is_polygon( geometry ) )  as from_real_geom
      ,osm_ids2mbid ( id,   false                  )  as from_fake_geom_false
      ,osm_ids2mbid ( id,   true                   )  as from_fake_geom_true
from osm_place_geometry ;
*/

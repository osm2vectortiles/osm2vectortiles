WITH vlayers AS (
  SELECT * FROM compare_layer_feature_count(
    'osm_admin_linestring',
    array['osm_admin_linestring'],
    array['admin_layer']
  )
  UNION SELECT * FROM compare_layer_feature_count(
    'osm_aero_*',
    array['osm_aero_linestring', 'osm_aero_polygon'],
    array['aeroway_layer']
  )
  UNION SELECT * FROM compare_layer_feature_count(
    'osm_airport_*',
    array['osm_airport_point', 'osm_airport_polygon'],
    array['airport_label_layer']
  )
  UNION SELECT * FROM compare_layer_feature_count(
    'osm_barrier_*',
    array['osm_barrier_linestring', 'osm_barrier_polygon'],
    array['barrier_line_layer']
  )
  UNION SELECT * FROM compare_layer_feature_count(
    'osm_place_*',
    array['osm_place_geometry'],
    array['place_label_layer']
  )
  UNION SELECT * FROM compare_layer_feature_count(
    'osm_poi_*',
    array['osm_poi_point', 'osm_poi_polygon'],
    array['poi_label_layer']
  )
  UNION SELECT * FROM compare_layer_feature_count(
    'osm_rail_station_point',
    array['osm_rail_station_point'],
    array['rail_station_label_layer']
  )
  UNION SELECT * FROM compare_layer_feature_count(
    'osm_road_geometry',
    array['osm_road_geometry'],
    array['road_layer', 'road_label_layer']
  )
  UNION SELECT * FROM compare_layer_feature_count(
    'osm_water_polygon_*',
    array['osm_water_polygon_gen1', 'osm_water_polygon', 'osm_water_point'],
    array['water_layer', 'water_label_layer']
  )
  UNION SELECT * FROM compare_layer_feature_count(
    'osm_water_linestring',
    array['osm_water_linestring'],
    array['waterway_layer', 'waterway_label_layer']
  )
  UNION SELECT * FROM compare_layer_feature_count(
    'osm_building_*',
    array['osm_building_polygon_gen0', 'osm_building_polygon'],
    array['building_layer']
  )
  UNION SELECT * FROM compare_layer_feature_count(
    'osm_housenumber_*',
    array['osm_housenumber_point', 'osm_housenumber_polygon'],
    array['housenum_label_layer']
  )
  UNION SELECT * FROM compare_layer_feature_count(
    'osm_landuse_*',
    array['osm_landuse_polygon', 'osm_landuse_polygon_gen0', 'osm_landuse_polygon_gen1'],
    array['landuse_overlay_layer', 'landuse_layer']
  )
  UNION SELECT * FROM compare_layer_feature_count(
    'osm_mountain_peak_point',
    array['osm_mountain_peak_point'],
    array['mountain_peak_label_layer']
  )
)
SELECT *, round((used_features::numeric * 100) / all_features::numeric, 2) as percent
FROM vlayers
ORDER BY tid;

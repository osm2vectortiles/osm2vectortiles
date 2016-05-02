UPDATE osm_place_point
SET geometry = topoint(geometry)
WHERE ST_GeometryType(geometry) <> 'ST_Point';

UPDATE osm_poi_polygon
SET geometry = topoint(geometry)
WHERE ST_GeometryType(geometry) <> 'ST_Point';

UPDATE osm_housenumber_polygon
SET geometry = topoint(geometry)
WHERE ST_GeometryType(geometry) <> 'ST_Point';

UPDATE osm_place_point
SET geometry = ST_PointOnSurface(geometry)
WHERE ST_GeometryType(geometry) <> 'ST_Point';

UPDATE osm_poi_polygon
SET geometry = ST_PointOnSurface(geometry)
WHERE ST_GeometryType(geometry) <> 'ST_Point';

UPDATE osm_housenumber_polygon
SET geometry = ST_PointOnSurface(geometry)
WHERE ST_GeometryType(geometry) <> 'ST_Point';

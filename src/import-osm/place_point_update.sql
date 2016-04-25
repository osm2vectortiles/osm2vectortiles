UPDATE osm_place_point
SET geometry = topoint(geometry)
WHERE ST_GeometryType(geometry) <> 'ST_Point';

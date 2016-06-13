DROP INDEX IF EXISTS osm_road_geometry_class;
CREATE INDEX osm_road_geometry_class ON osm_road_geometry(road_class(type, service, access));

DROP INDEX IF EXISTS osm_landuse_polygon;
CREATE INDEX osm_landuse_polygon_area ON osm_landuse_polygon(ST_Area(geometry));

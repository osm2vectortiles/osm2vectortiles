DROP INDEX IF EXISTS osm_road_geometry_class;
CREATE INDEX osm_road_geometry_class ON osm_road_geometry(road_class(type, service, access));

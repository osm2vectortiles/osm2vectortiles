.PHONY: all

all: postgis export import-osm import-external import-sql update-scaleranks detect-dirty-tiles

postgis:
	docker build -t osm2vectortiles/postgis src/postgis

export:
	docker build -t osm2vectortiles/export src/export

import-osm:
	docker build -t osm2vectortiles/import-osm src/import-osm

import-external:
	docker build -t osm2vectortiles/import-external src/import-external

import-sql:
	docker build -t osm2vectortiles/import-sql src/import-sql

update-scaleranks:
	docker build -t osm2vectortiles/update-scaleranks src/update-scaleranks

detect-dirty-tiles:
	docker build -t osm2vectortiles/detect-dirty-tiles src/detect-dirty-tiles


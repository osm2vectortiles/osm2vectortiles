.PHONY: all

all: postgis export-mbtiles import-osm import-external import-sql update-scaleranks create-extracts changed-tiles generate-jobs merge-jobs compare-visual

fast: postgis export-mbtiles import-osm import-sql update-scaleranks create-extracts changed-tiles generate-jobs merge-jobs

postgis:
	docker build -t osm2vectortiles/postgis src/postgis

export-mbtiles:
	docker build -t osm2vectortiles/export src/export

import-osm:
	docker build -t osm2vectortiles/import-osm src/import-osm

import-external:
	docker build -t osm2vectortiles/import-external src/import-external

import-sql:
	docker build -t osm2vectortiles/import-sql src/import-sql

update-scaleranks:
	docker build -t osm2vectortiles/update-scaleranks src/update-scaleranks

create-extracts:
	docker build -t osm2vectortiles/create-extracts src/create-extracts

changed-tiles:
	docker build -t osm2vectortiles/changed-tiles src/changed-tiles

generate-jobs:
	docker build -t osm2vectortiles/generate-jobs src/generate-jobs

merge-jobs:
	docker build -t osm2vectortiles/merge-jobs src/merge-jobs

compare-visual:
	docker build -t osm2vectortiles/compare-visual tools/compare-visual

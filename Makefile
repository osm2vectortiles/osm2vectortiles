.PHONY: all

all: postgis export-mbtiles import-osm import-external import-sql create-extracts changed-tiles generate-jobs merge-jobs compare-visual mapping-qa-report

fast: export-mbtiles import-osm import-sql create-extracts changed-tiles generate-jobs merge-jobs

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

mapping-qa-report:
	docker build -t osm2vectortiles/mapping-qa-report tools/mapping-qa-report

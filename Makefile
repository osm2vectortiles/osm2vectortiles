NAMESPACE = osm2vectortiles
POSTGIS_IMAGE = $(NAMESPACE)/postgis
IMPOSM_IMAGE = $(NAMESPACE)/imposm3

CWD = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PGDATA_DIR = $(CWD)/pgdata
IMPORT_DATA_DIR = $(CWD)/import
IMPORT_CACHE_DIR = $(CWD)/cache

OSM_DB = "osm_zurich"
OSM_USER = "osm"
OSM_PASSWORD = "7G@VNDYa&Zp<726x"
ZURICH_PBF = https://s3.amazonaws.com/metro-extracts.mapzen.com/zurich_switzerland.osm.pbf

postgis:
	docker build -t $(POSTGIS_IMAGE) ./database/postgis

imposm3:
	docker build -t $(IMPOSM_IMAGE) ./database/imposm3

docker: postgis imposm3

prepare:
	mkdir -p $(PGDATA_DIR)
	mkdir -p $(IMPORT_DATA_DIR)
	mkdir -p $(IMPORT_CACHE_DIR)

build: docker

import: prepare docker
	wget --directory-prefix $(IMPORT_DATA_DIR) --no-clobber $(ZURICH_PBF)
	docker run --name postgis \
		-v $(PGDATA_DIR):/var/lib/postgresql/data \
		-e OSM_DB=$(OSM_DB) \
		-e OSM_USER=$(OSM_USER) \
		-e OSM_PASSWORD=$(OSM_PASSWORD) \
		-d $(POSTGIS_IMAGE)
	sleep 20
    @echo "Wait until PostGIS is initialized"
	docker run --rm --name imposm \
		-v $(IMPORT_DATA_DIR):/data/import \
		-v $(IMPORT_CACHE_DIR):/data/cache \
		--link postgis:db \
		-e OSM_DB=$(OSM_DB) \
		-e OSM_USER=$(OSM_USER) \
		-e OSM_PASSWORD=$(OSM_PASSWORD) \
		osm2vectortiles/imposm3

default: build

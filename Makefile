NAMESPACE = osm2vectortiles
POSTGIS_IMAGE = $(NAMESPACE)/postgis
IMPOSM_IMAGE = $(NAMESPACE)/imposm3
TILELIVE_IMAGE = $(NAMESPACE)/tilelive

CWD = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PGDATA_DIR = $(CWD)/pgdata
IMPORT_DATA_DIR = $(CWD)/import
EXPORT_DATA_DIR = $(CWD)/export
IMPORT_CACHE_DIR = $(CWD)/cache

OSM_DB = "osm_zurich"
OSM_USER = "osm"
OSM_PASSWORD = "7G@VNDYa&Zp<726x"
ZURICH_PBF = https://s3.amazonaws.com/metro-extracts.mapzen.com/zurich_switzerland.osm.pbf
ZURICH_BBOX = "8.4039 47.3137 8.6531 47.4578"

postgis:
	docker build -t $(POSTGIS_IMAGE) ./database/postgis

imposm3:
	docker build -t $(IMPOSM_IMAGE) ./database/imposm3

tilelive:
	docker build -t $(TILELIVE_IMAGE) ./database/tilelive

docker: postgis imposm3 tilelive

prepare:
	mkdir -p $(PGDATA_DIR); \
    mkdir -p $(IMPORT_DATA_DIR); \
	mkdir -p $(IMPORT_CACHE_DIR); \
	mkdir -p $(EXPORT_DATA_DIR);

build: docker

test: build export

export: import
	docker run --rm \
		-v $(pwd)/export3:/data/export \
		-v $(pwd)/osm-bright-2.tm2source:/project \
		-e MIN_ZOOM=12 \
		-e MAX_ZOOM=14 \
		-e BBOX="$(ZURICH_BBOX)" \
		-e OSM_DB=$(OSM_DB) \
		-e OSM_USER=$(OSM_USER) \
		-e OSM_PASSWORD=$(OSM_PASSWORD) \
		--name export \
		--link postgis:db \
		osm2vectortiles/tilelive

import: prepare docker
	wget --directory-prefix $(IMPORT_DATA_DIR) --no-clobber $(ZURICH_PBF); \
	docker run --name postgis \
		-v $(PGDATA_DIR):/var/lib/postgresql/data \
		-e OSM_DB=$(OSM_DB) \
		-e OSM_USER=$(OSM_USER) \
		-e OSM_PASSWORD=$(OSM_PASSWORD) \
		-d $(POSTGIS_IMAGE); \
    echo "Wait until PostGIS is initialized"; \
	sleep 20; \
	docker logs postgis; \
	docker run --rm --name imposm \
		-v $(IMPORT_DATA_DIR):/data/import \
		-v $(IMPORT_CACHE_DIR):/data/cache \
		--link postgis:db \
		-e OSM_DB=$(OSM_DB) \
		-e OSM_USER=$(OSM_USER) \
		-e OSM_PASSWORD=$(OSM_PASSWORD) \
		osm2vectortiles/imposm3

default: test

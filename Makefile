NAMESPACE = osm2vectortiles

postgis:
	docker build -t $(NAMESPACE)/postgis ./database/postgis

imposm3:
	docker build -t $(NAMESPACE)/imposm3 ./database/imposm3

docker: postgis imposm3

build: docker

default: build

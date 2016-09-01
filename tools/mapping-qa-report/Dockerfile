FROM osm2vectortiles/import-osm

RUN apt-get update \
 && apt-get install -y --no-install-recommends git \
 && rm -rf /var/lib/apt/lists/*

RUN go get github.com/lukasmartinelli/pgclimb \
 && go install github.com/lukasmartinelli/pgclimb

VOLUME /qa
ENV QA_DIR="/qa"

WORKDIR /usr/src/app
COPY . /usr/src/app
CMD ["./export-mapping-report.sh"]

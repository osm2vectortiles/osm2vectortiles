FROM golang:1.5.3

RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*

RUN go get github.com/lukasmartinelli/pgclimb \
 && go install github.com/lukasmartinelli/pgclimb

VOLUME /data
ENV EXPORT_DIR="/data"

WORKDIR /usr/src/app
COPY . /usr/src/app
CMD ["./export-mapping-report.sh"]

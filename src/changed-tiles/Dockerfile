FROM golang:1.5.3

RUN go get github.com/lukasmartinelli/pgclimb \
 && go install github.com/lukasmartinelli/pgclimb

VOLUME /data
ENV EXPORT_DIR="/data/export"

WORKDIR /usr/src/app
COPY . /usr/src/app
CMD ["./export-changed-tiles.sh"]


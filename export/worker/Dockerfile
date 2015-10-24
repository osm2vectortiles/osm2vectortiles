FROM node:0.10
MAINTAINER Lukas Martinelli <me@lukasmartinelli.ch>

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN npm install -g tl \
	   mbtiles \
           tilelive-tmsource \
           tilelive-vector \
	   tilelive-bridge \
	   tilelive-mapnik

RUN apt-get update && apt-get install -y --no-install-recommends \
        python \
        python-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip install boto

# custom tm2source project
VOLUME /data/tm2source
ENV SOURCE_PROJECT_DIR=/data/tm2source

# destination for exported vector tiles
VOLUME /data/export
ENV EXPORT_DIR=/data/export

COPY export.sh /usr/src/app/export.sh
COPY execute_jobs.py /usr/src/app/execute_jobs.py

CMD ["/usr/src/app/export.sh"]

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

COPY requirements.txt /usr/src/app/requirements.txt
RUN pip install -r requirements.txt

# custom tm2source project
RUN git clone https://github.com/geometalab/open-streets.tm2source /data/tm2source
ENV SOURCE_PROJECT_DIR=/data/tm2source

# destination for exported vector tiles
VOLUME /data/export
ENV EXPORT_DIR=/data/export

COPY export.py /usr/src/app/
COPY export.sh /usr/src/app/
CMD ["/usr/src/app/export.sh"]

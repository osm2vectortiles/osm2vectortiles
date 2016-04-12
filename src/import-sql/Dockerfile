FROM python:3.4

RUN apt-get update && apt-get install -y --no-install-recommends \
      postgresql-client \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/lukasmartinelli/classify.git /opt/classify
WORKDIR /opt/classify
RUN pip install -r requirements.txt

ENV SQL_FUNCTIONS_FILE=/usr/src/app/functions.sql \
    SQL_TRIGGERS_FILE=/usr/src/app/triggers.sql \
    SQL_XYZ_EXTENT_FILE=/usr/src/app/xyz_extent.sql \
    SQL_VIEWS_DIR=/usr/src/app/views/ \
    PATH=$PATH:/opt/classify
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN classify.py sql classes/barrier_line.yml >> $SQL_FUNCTIONS_FILE \
 && classify.py sql classes/landuse_overlay.yml >> $SQL_FUNCTIONS_FILE \
 && classify.py sql classes/landuse.yml >> $SQL_FUNCTIONS_FILE \
 && classify.py sql classes/road.yml >> $SQL_FUNCTIONS_FILE \
 && classify.py sql classes/rail_station.yml >> $SQL_FUNCTIONS_FILE \
 && classify.py sql classes/maki_label.yml >> $SQL_FUNCTIONS_FILE
CMD ["./prepare.sh"]

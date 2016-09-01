FROM python:3.4

ENV SQL_FUNCTIONS_FILE=/usr/src/app/functions.sql \
    SQL_GENERATED_FILE=/usr/src/app/gen.sql \
    SQL_INDIZES_FILE=/usr/src/app/indizes.sql \
    SQL_LAYERS_DIR=/usr/src/app/layers/ \
    VT_UTIL_FILE=/usr/src/vt-util.sql \
    VT_UTIL_VERSION=1.0.0

RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*

RUN curl -o $VT_UTIL_FILE https://raw.githubusercontent.com/mapbox/postgis-vt-util/v1.0.0/postgis-vt-util.sql

WORKDIR /usr/src/app/
COPY requirements.txt /usr/src/app/
RUN pip install -r requirements.txt

COPY . /usr/src/app
RUN ./generate_sql.py class classes/barrier_line.yml >> $SQL_GENERATED_FILE \
 && ./generate_sql.py class classes/landuse_overlay.yml >> $SQL_GENERATED_FILE \
 && ./generate_sql.py class classes/landuse.yml >> $SQL_GENERATED_FILE \
 && ./generate_sql.py class classes/road.yml >> $SQL_GENERATED_FILE \
 && ./generate_sql.py class classes/rail_station.yml >> $SQL_GENERATED_FILE \
 && ./generate_sql.py class classes/maki_label.yml >> $SQL_GENERATED_FILE

CMD ["./prepare.sh"]

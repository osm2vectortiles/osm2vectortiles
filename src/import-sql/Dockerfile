FROM python:3.4

RUN apt-get update && apt-get install -y --no-install-recommends \
      postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app/
COPY requirements.txt /usr/src/app/
RUN pip install -r requirements.txt

ENV SQL_FUNCTIONS_FILE=/usr/src/app/functions.sql \
    SQL_GENERATED_FILE=/usr/src/app/gen.sql \
    SQL_TRIGGERS_FILE=/usr/src/app/triggers.sql \
    SQL_XYZ_EXTENT_FILE=/usr/src/app/xyz_extent.sql \
    SQL_INDIZES_FILE=/usr/src/app/indizes.sql \
    SQL_LAYERS_DIR=/usr/src/app/layers/ \
    SQL_SPLIT_POLYGON_FILE=/usr/src/app/landuse_split_polygon_table.sql \
    SQL_SUBDIVIDE_POLYGON_FILE=/usr/src/app/subdivide_polygons.sql
COPY . /usr/src/app

# Generate class functions
RUN ./generate_sql.py class classes/barrier_line.yml >> $SQL_GENERATED_FILE \
 && ./generate_sql.py class classes/landuse_overlay.yml >> $SQL_GENERATED_FILE \
 && ./generate_sql.py class classes/landuse.yml >> $SQL_GENERATED_FILE \
 && ./generate_sql.py class classes/road.yml >> $SQL_GENERATED_FILE \
 && ./generate_sql.py class classes/rail_station.yml >> $SQL_GENERATED_FILE \
 && ./generate_sql.py class classes/maki_label.yml >> $SQL_GENERATED_FILE

# Generate table functions
RUN ./generate_sql.py changed_tiles tables.yml >> $SQL_GENERATED_FILE \
 && ./generate_sql.py tables tables.yml >> $SQL_GENERATED_FILE

CMD ["./prepare.sh"]

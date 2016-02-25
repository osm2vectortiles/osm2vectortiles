FROM python:3.4

RUN apt-get update && apt-get install -y --no-install-recommends \
      postgresql-client \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/lukasmartinelli/classify.git /opt/classify
WORKDIR /opt/classify
RUN pip install -r requirements.txt

ENV SQL_FILE=/usr/src/app/functions.sql \
    PATH=$PATH:/opt/classify
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN classify.py sql classes/barrier_line.yml >> functions.sql \
 && classify.py sql classes/landuse_overlay.yml >> functions.sql \
 && classify.py sql classes/landuse.yml >> functions.sql \
 && classify.py sql classes/road.yml >> functions.sql \
 && classify.py sql classes/maki_label.yml >> functions.sql
CMD ["./prepare.sh"]

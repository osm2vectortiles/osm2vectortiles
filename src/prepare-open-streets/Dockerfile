FROM python:3.4

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY requirements.txt /usr/src/app/requirements.txt
RUN pip install -r requirements.txt

RUN apt-get update && apt-get install -y --no-install-recommends \
      postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY . /usr/src/app
RUN ./generate_sql.py classify.yml >> functions.sql

ENV SQL_FILE=/usr/src/app/functions.sql
CMD ["./prepare.sh"]

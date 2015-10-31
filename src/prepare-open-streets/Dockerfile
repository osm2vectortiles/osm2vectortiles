FROM mdillon/postgis:9.4

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/geometalab/open-streets.tm2source /usr/src/app
WORKDIR /usr/src/app
ENV SQL_FILE=/usr/src/app/functions.sql

COPY prepare.sh /usr/src/app/

CMD ["./prepare.sh"]

FROM ubuntu:16.04

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      apt-transport-https \
      ca-certificates \
      python \
      python-yaml \
      git

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app


CMD ["./generate_tm2source.sh"]

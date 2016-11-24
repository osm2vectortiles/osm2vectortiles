FROM python:3.4
RUN wget -O /usr/bin/pipecat https://github.com/lukasmartinelli/pipecat/releases/download/v0.3/pipecat_linux_amd64 \
 && chmod +x /usr/bin/pipecat

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY requirements.txt /usr/src/app/
RUN pip install --no-cache-dir -r requirements.txt

COPY . /usr/src/app
CMD ["./generate_world_jobs.sh"]

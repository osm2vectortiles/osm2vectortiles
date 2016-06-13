FROM python:3.4-onbuild
RUN wget -O pipecat https://github.com/lukasmartinelli/pipecat/releases/download/v0.2/pipecat_linux_amd64 \
 && chmod +x pipecat
CMD ["./generate_world_jobs.sh"]

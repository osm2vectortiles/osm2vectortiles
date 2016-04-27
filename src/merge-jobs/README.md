# merge-jobs

The **merge-jobs** component is responsible for taking result messages from the queue,
download the attached MBTiles file and merge it into the latest planet MBTiles file.

![Flow Diagram](merge-jobs-flow-diagram.png)

## Usage

### Docker

To use **merge-jobs** inside the Docker Compose workflow you only need to ensure
that you have a `planet.mbtiles` ready in the `export` folder.

Now **merge-jobs** will merge the MBTiles files into `./export/planet.mbtiles`.

```
docker-compose run merge-jobs
```

### Python

You can execute **merge-jobs** CLI directly as well without the wrapper Bash script.
You can also configure the name of the queue to pull messages from
with `--result-queue=<result-queue>`. You need to set the MBTiles merge target explicitly
via `--merge-target<mbtiles-file>` to the MBTiles you want the MBTiles job results merged into.


```
merge-jobs.py <rabbitmq_url>  --merge-target=<mbtiles-file> [--result-queue=<result-queue>]
```

## Troubleshooting

### Check Queue Length

To get started you will need to have result messages in the message queue.

```bash
# Check queue length on local RabbitMQ instance
rabbitmqctl list_queues

# Or attach to Docker container running RabbitMQ
docker exec <rabbit-container-id> rabbitmqctl list_queues
```

### S3 Files not accessible

The **merge-jobs** component does need **public access** to the files referenced
in the results message. If the bucket is not public you need to explicitely
make all object inside the bucket public.

```bash
s3cmd setacl s3://osm2vectortiles-jobs/ --acl-public --recursive
```

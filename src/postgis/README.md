# postgis

The **postgis** component is the stateful PostgreSQL database container and is linked by most other components.

## Usage

### Docker

You should start the **postgis** container before doing anything else.
The **postgis** container is used in conjunction with the **pgdata** data container.
You can mount the volume directly to a filesystem location by modifying the `docker-compose.yml` file.

```
docker-compose up -d postgis
```

## Troubleshooting

Verify it has started correctly if you cannot import data afterwards with `docker-compose logs postgis`.

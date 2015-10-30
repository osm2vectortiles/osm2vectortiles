## Develop with Mapbox Studio

Running Mapbox Studio in a Docker container allows to link the database
container directly to the Mapbox Studio container. Whether you are
on the server with the fast database or working on a local machine.

### Setup

Inside the osm2vectortiles repository clone [open-streets.tm2source](https://github.com/geometalab/open-streets.tm2source).

```
git clone https://github.com/geometalab/open-streets.tm2source
```

### Run Mapbox Studio

Make sure the `postgis` container is up and running.

```
docker-compose up -d postgis
```

Start up `mapbox-studio`.

```
docker-compose mapbox-studio
```

You can now visit `localhost:3000` to access Mapbox Studio (or look for
the appropriate port in Kitematic on OSX).

### Choose Project

The `open-streets.tm2source` project is mounted to `/tm2source`.
To start editing open the source project from this path.

### Authorize Mapbox Studio on OSX

Mapbox Studio redirects the OAuth requests to localhost. Because Docker
is not native on OSX this is a bit problematic.

On the first start for the authorizing you need to forward localhost traffic
on port `3000` to the remote docker host.

Install netcat.

```
brew install netcat
```

Pipe incoming traffic to docker container and pipe outcoming traffic from container back. Look for your local Docker IP in the Kitematic interface.

```
mkfifo backpipe
nc -l 3000 | nc 192.168.99.100 3000 1> backpipe
```

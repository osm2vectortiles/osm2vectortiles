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

The `open-streets.tm2source` project is mounted to the `/projects` folder.
Choose existing project and open open the source project from this path.

### Authorize Mapbox Studio on OSX

Mapbox Studio redirects the OAuth requests to localhost. Because Docker
is running on a virtual machine on OSX on a different IP this does not work.

You will receive the following OAuth callback in the browser which results in a `ERR_CONNECTION_REFUSED` error on OSX.

```
http://localhost:3000/oauth/mapbox?code=XQBLTQ2...
```

Change the hostname of the URL to your Docker IP address and make the OAuth callback yourself.

```
http://192.168.99.100/oauth/mapbox?code=XQBLTQ2...
```

This only needs to be done the first time your start up Mapbox Studio in a Docker container.

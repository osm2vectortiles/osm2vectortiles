# Serve Vector Tiles

We provide a free and fast CDN for accessing the vector tiles.
But you have the choice to self host the vector tiles if you want to.

## tileserver-php

For serving vector tiles we recommend using
[https://github.com/klokantech/tileserver-php](tileserver-php from Klokan Technologies)
which supports serving MBTiles containing vector tile PBFs out of the box.

### Installation

If you have an Apache webhosting this is the easiest option to get started.
Follow the [installation instructions](https://github.com/klokantech/tileserver-php#installation) to set
up tileserver-php on your server.

### Download MBTiles

On the server download your desired extract of a country or the
entire world MBTiles from http://osm2vectortiles.org/data/download.html.
Put it in the public folder `/var/www/` and you are good to go.

### Docker

You can also run tileserver-php with Docker

Pull down the latest image.

```bash
docker pull klokantech/tileserver-php
```

And mount the directory with the MBTiles to the public folder.

```bash
docker run -v $(pwd):/var/www -p 80:80 klokantech/tileserver-php
```

## Tessera

Tessera is also able to serve vector tiles instead of raster tiles to clients.

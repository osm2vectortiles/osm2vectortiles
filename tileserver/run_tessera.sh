#!/bin/bash

PORT=80 tessera mbtiles:///data/countries.mbtiles &
PORT=8080 tessera tmstyle:///data/countries.tm2 

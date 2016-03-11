-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION osm2vectortiles" to load this file. \quit

CREATE TYPE tile AS (x integer, y integer, z integer);
CREATE OR REPLACE FUNCTION point_to_tiles(lat double precision, lon double precision, max_zoom_level integer)
    RETURNS SETOF tile
	AS '$libdir/osm2vectortiles', 'point_to_tiles'
    LANGUAGE C IMMUTABLE STRICT;

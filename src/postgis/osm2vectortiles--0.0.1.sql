-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION osm2vectortiles" to load this file. \quit

CREATE OR REPLACE FUNCTION point_to_tiles(lat double precision, lon double precision, max_zoom_level integer)
    RETURNS TABLE (x INTEGER, y INTEGER, z INTEGER)
	AS '$libdir/osm2vectortiles', 'point_to_tiles'
    LANGUAGE C IMMUTABLE STRICT;

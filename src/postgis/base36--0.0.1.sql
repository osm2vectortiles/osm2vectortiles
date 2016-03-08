-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION base36" to load this file. \quit

CREATE TYPE tile AS (x integer, y integer, z integer);
CREATE OR REPLACE FUNCTION point_to_tiles(lat double precision, lon double precision)
    RETURNS SETOF tile 
	AS '$libdir/base36', 'retcomposite'
    LANGUAGE C IMMUTABLE STRICT;

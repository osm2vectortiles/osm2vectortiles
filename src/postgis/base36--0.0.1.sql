-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION base36" to load this file. \quit
CREATE FUNCTION base36_encode(integer) RETURNS text
AS '$libdir/base36'
LANGUAGE C IMMUTABLE STRICT;

-- Return pixel resolution at the given zoom level
CREATE OR REPLACE FUNCTION XYZ_Resolution(z INTEGER)
RETURNS FLOAT8
AS $$
  -- circumference divided by 256 is z0 resolution, then divide by 2^z
  SELECT 40075017.0 / 256 / power(2, z);
$$ LANGUAGE SQL IMMUTABLE STRICT;

-- Returns a polygon representing the bounding box of a given XYZ tile
CREATE OR REPLACE FUNCTION XYZ_Extent(x INTEGER, y INTEGER, z INTEGER, buffer INTEGER)
RETURNS GEOMETRY
AS $$
DECLARE
  origin_shift FLOAT8;
  initial_resolution FLOAT8;
  tile_geo_size FLOAT8;
  pixres FLOAT8;
  xmin FLOAT8;
  ymin FLOAT8;
  xmax FLOAT8;
  ymax FLOAT8;
  earth_circumference FLOAT8;
  tile_size INTEGER;
BEGIN
  -- Size of each tile in pixels (1:1 aspect ratio)
  tile_size := 256 + (2 * buffer);

  initial_resolution := XYZ_Resolution(0);

  origin_shift := (initial_resolution * tile_size) / 2.0;

  pixres := initial_resolution / (power(2,z));

  tile_geo_size = tile_size * pixres;

  xmin := -origin_shift + x*tile_geo_size;
  xmax := -origin_shift + (x+1)*tile_geo_size;

  ymin := origin_shift - y*tile_geo_size;
  ymax := origin_shift - (y+1)*tile_geo_size;

  RETURN ST_MakeEnvelope(xmin, ymin, xmax, ymax, 3857);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

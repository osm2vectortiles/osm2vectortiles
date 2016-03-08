EXTENSION = osm2vectortiles        # the extensions name
DATA = osm2vectortiles--0.0.1.sql  # script files to install
REGRESS = osm2vectortiles_test
MODULES = osm2vectortiles          # our c module file to build

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

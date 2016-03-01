CREATE OR REPLACE VIEW place_label_z4toz5 AS
    SELECT *
    FROM osm_places
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank < 3;

CREATE OR REPLACE VIEW place_label_z6 AS
    SELECT *
    FROM osm_places
    WHERE name <> ''
      AND scalerank IS NOT NULL
      AND scalerank < 8;

CREATE OR REPLACE VIEW place_label_z7 AS
    SELECT *
    FROM osm_places
    WHERE name <> ''
      AND scalerank IS NOT NULL;

CREATE OR REPLACE VIEW place_label_z8 AS
    SELECT *
    FROM osm_places
    WHERE name <> ''
      AND type IN ('city', 'town');

CREATE OR REPLACE VIEW place_label_z9toz10 AS
    SELECT *
    FROM osm_places
    WHERE name <> ''
      AND type IN ('city', 'town', 'district');

CREATE OR REPLACE VIEW place_label_z11toz12 AS
    SELECT *
    FROM osm_places
    WHERE name <> ''
      AND type IN ('city', 'town', 'district', 'village');

CREATE OR REPLACE VIEW place_label_z13 AS
    SELECT *
    FROM osm_places
    WHERE name <> ''
      AND type IN ('city', 'town', 'district', 'village', 'hamlet', 'suburb','neighbourhood');

CREATE OR REPLACE VIEW place_label_z14 AS
    SELECT *
    FROM osm_places
    WHERE name <> '';

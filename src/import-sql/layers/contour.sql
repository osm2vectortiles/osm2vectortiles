
CREATE OR REPLACE VIEW contour_z8toz9 AS
    SELECT id AS osm_id, height as ele, geometry
    FROM contour_lines_gen0
	WHERE ((cast(height as integer)%100) = 0);

CREATE OR REPLACE VIEW contour_z10toz11 AS
    SELECT id AS osm_id, height as ele, geometry
    FROM contour_lines_gen0
	WHERE ((cast(height as integer)%50) = 0);

CREATE OR REPLACE VIEW contour_z12toz13 AS
    SELECT id AS osm_id, height as ele, geometry
    FROM contour_lines_gen1;

CREATE OR REPLACE VIEW contour_z14 AS
    SELECT id AS osm_id, height as ele, geometry
    FROM contour_lines;



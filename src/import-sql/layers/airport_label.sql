CREATE OR REPLACE VIEW airport_label_z9toz14 AS
    SELECT id AS osm_id, geometry, name, name_en, name_es, name_fr, name_de, name_ru, name_zh, 
        iata, ref, icao, faa, aerodrome, type, kind, 0 AS area
    FROM osm_airport_point
    UNION ALL
    SELECT id AS osm_id, geometry, name, name_en, name_es, name_fr, name_de,
        name_ru, name_zh, iata, ref, icao, faa, aerodrome, type, kind, area
    FROM osm_airport_polygon;

CREATE OR REPLACE VIEW airport_label_layer AS (
    SELECT osm_id FROM airport_label_z9toz14
);

CREATE OR REPLACE FUNCTION airport_label_scalerank(maki VARCHAR, area REAL, aerodrome VARCHAR) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE
        WHEN (maki = 'airport' AND area >= 300000) OR aerodrome = 'international' THEN 1
        WHEN maki = 'airport' AND area < 300000 THEN 2
        WHEN maki = 'airfield' AND area >= 145000 THEN 3
        WHEN maki = 'airfield' AND area < 145000 THEN 4
        ELSE 4
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION airport_label_class(kind VARCHAR, type VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN kind = 'heliport' THEN 'heliport'
        WHEN kind = 'aerodrome' AND type IN ('public', 'Public') THEN 'airport'
        WHEN kind = 'aerodrome' AND type IN ('private', 'Private', 'military/public', 'Military/Public') THEN 'airfield'
        ELSE 'airfield'
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

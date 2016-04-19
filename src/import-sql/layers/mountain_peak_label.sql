CREATE OR REPLACE VIEW mountain_peak_label_z12toz14 AS
    SELECT *
    FROM osm_mountain_peak_point;

CREATE OR REPLACE FUNCTION meter_to_feet(meter INTEGER) RETURNS INTEGER
AS $$
BEGIN
    RETURN round(meter * 3.28084);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION mountain_peak_type(type VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    IF type = 'volcano' THEN
        RETURN type;
    ELSE
        RETURN 'mountain';
    END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

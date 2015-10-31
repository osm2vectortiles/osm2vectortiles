CREATE OR REPLACE FUNCTION classify_road(type VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN type IN ('motorway', 'motorway_link', 'driveway') THEN 'highway'
        WHEN type IN ('primary', 'primary_link', 'trunk', 'trunk_link', 'secondary', 'secondary_link', 'tertiary', 'tertiary_link') THEN 'main'
        WHEN type IN ('residential', 'unclassified', 'living_street') THEN 'street'
        WHEN type IN ('pedestrian', 'construction', 'private') THEN 'street_limited'
        WHEN type IN ('rail', 'monorail', 'narrow_gauge', 'subway', 'tram') THEN 'major_rail'
        WHEN type IN ('service', 'track') THEN 'service'
        WHEN type IN ('path', 'cycleway', 'ski', 'steps', 'bridleway', 'footway') THEN 'path'
        WHEN type IN ('funicular', 'light_rail', 'preserved') THEN 'minor_rail'
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION maki_label(class VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN REPLACE(class, '_', '-');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

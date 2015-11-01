CREATE OR REPLACE FUNCTION classify_road(type VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN type IN ('motorway', 'motorway_link', 'driveway') THEN 'highway'
        WHEN type IN ('primary', 'primary_link', 'trunk', 'trunk_link', 'secondary', 'secondary_link', 'tertiary', 'tertiary_link') THEN 'main'
        WHEN type IN ('residential', 'unclassified', 'living_street') THEN 'street'
        WHEN type IN ('pedestrian', 'construction', 'private') THEN 'street_limited'
        WHEN type IN ('service', 'track') THEN 'service'
        WHEN type IN ('path', 'cycleway', 'ski', 'steps', 'bridleway', 'footway') THEN 'path'
        WHEN type IN ('rail', 'monorail', 'narrow_gauge', 'subway') THEN 'major_rail'
        WHEN type IN ('funicular', 'light_rail', 'preserved', 'tram') THEN 'minor_rail'
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION classify_landuse(type VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN type IN ('orchard', 'farm', 'farmland', 'farmyard', 'allotments', 'vineyard', 'plant_nursery') THEN 'agriculture'
        WHEN type IN ('cemetery','christian', 'jewish') THEN 'cemetery'
        WHEN type IN ('glacier') THEN 'glacier'
        WHEN type IN ('grass', 'grassland', 'meadow') THEN 'grass'
        WHEN type IN ('hospital') THEN 'hospital'
        WHEN type IN ('industrial') THEN 'industrial'
        WHEN type IN ('park', 'dog_park', 'common', 'garden', 'golf_course', 'playground', 'recreation_ground', 'nature_reserve', 'sports_centre', 'village_green', 'zoo') THEN 'park'
        WHEN type IN ('athletics', 'chess', 'pitch') THEN 'pitch'
        WHEN type IN ('sand') THEN 'sand'
        WHEN type IN ('school', 'college', 'university') THEN 'school'
        WHEN type IN ('scrub') THEN 'scrub'
        WHEN type IN ('wood', 'forest') THEN 'wood'
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION maki_label(class VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN REPLACE(class, '_', '-');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

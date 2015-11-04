CREATE OR REPLACE FUNCTION classify_road(type VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN type IN ('motorway') THEN 'motorway'
        WHEN type IN ('motorway_link') THEN 'motorway_link'
        WHEN type IN ('primary', 'primary_link', 'trunk', 'trunk_link', 'secondary', 'secondary_link', 'tertiary', 'tertiary_link') THEN 'main'
        WHEN type IN ('residential', 'unclassified', 'living_street', 'road', 'raceway') THEN 'street'
        WHEN type IN ('pedestrian', 'construction', 'private') THEN 'street_limited'
        WHEN type IN ('service', 'track', 'alley', 'spur', 'siding', 'crossover') THEN 'service'
        WHEN type IN ('driveway', 'parking_aisle') THEN 'driveway'
        WHEN type IN ('path', 'cycleway', 'ski', 'steps', 'bridleway', 'footway') THEN 'path'
        WHEN type IN ('rail', 'monorail', 'narrow_gauge', 'subway') THEN 'major_rail'
        WHEN type IN ('funicular', 'light_rail', 'preserved', 'tram', 'disused', 'yard') THEN 'minor_rail'
        WHEN type IN ('chair_lift', 'mixed_lift', 'drag_lift', 'platter', 't-bar', 'magic_carpet', 'gondola', 'cable_car', 'rope_tow', 'zip_line', 'j-bar', 'canopy') THEN 'aerialway'
        WHEN type IN ('hole') THEN 'golf'
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
        WHEN type IN ('wetland', 'swamp', 'bog', 'marsh') THEN 'wetland'
        WHEN type IN ('mud', 'tidalflat') THEN 'wetland_noveg'
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION classify_landuse_overlay(type VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN type IN ('wetland', 'marsh', 'swamp', 'bog') THEN 'wetland'
        WHEN type IN ('mud', 'tidalflat') THEN 'wetland_noveg'
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION maki_label(type VARCHAR) RETURNS VARCHAR
AS $$
BEGIN
    RETURN CASE
        WHEN type IN ('supermarket', 'deli', 'delicatessen', 'department_store', 'greengrocer') THEN 'grocery'
        WHEN type IN ('bag', 'clothes') THEN 'clothing-store'
        WHEN type IN ('hotel', 'motel', 'bed_and_breakfast', 'guest_house', 'hostel', 'chalet') THEN 'lodging'
        WHEN type IN ('books') THEN 'library'
        WHEN type IN ('alcohol', 'beverages', 'wine') THEN 'alcohol-shop'
        WHEN type IN ('accessories', 'antiques', 'art') THEN 'art-gallery'
        WHEN type IN ('car', 'car_repair') THEN 'car'
        WHEN type IN ('chocolate', 'confectionery') THEN 'ice-cream'
        WHEN type IN ('butcher') THEN 'slaughterhouse'
        WHEN type IN ('video', 'electronics') THEN 'camera'
        WHEN type IN ('gift') THEN 'gift'
        WHEN type IN ('public_building') THEN 'town-hall'
        WHEN type IN ('kindergarten') THEN 'school'
        WHEN type IN ('university', 'college') THEN 'college'
        WHEN type IN ('bed', 'carpet', 'doityourself', 'dry_cleaning', 'erotic', 'fabric', 'garden_centre',
                      'computer', 'general', 'video_games', 'furniture', 'hardware', 'hearing_aids',
                      'hifi', 'interior_decoration', 'lamps', 'toys', 'watches', 'weapons') THEN 'shop'
        WHEN REPLACE(type, '_', '-') IN (
            'aerialway', 'airfield', 'airport', 'alcohol-shop', 'america-football',
            'art-gallery', 'bakery', 'bank', 'bar', 'baseball', 'basketball', 'beer',
            'bicycle', 'building', 'bus', 'cafe', 'camera', 'campsite', 'car', 'cemetery',
            'chemist', 'cinema', 'circle', 'circle-stroked', 'city', 'clothing-store', 'college',
            'commercial', 'cricket', 'cross', 'dam', 'danger', 'dentist', 'disability', 'dog-park',
            'embassy', 'emergency-telephone', 'entrance', 'farm', 'fast-food', 'ferry', 'fire-station',
            'fuel', 'garden', 'gift', 'golf', 'grocery', 'hairdresser', 'harbor', 'heart', 'heliport',
            'hospital', 'ice-cream', 'industrial', 'land-use', 'laundry', 'library', 'lighthouse',
            'lodging', 'logging', 'london-underground', 'marker', 'marker-stroked', 'minefield',
            'mobilephone', 'monument', 'museum', 'music', 'oil-well', 'park', 'park2', 'parking',
            'parking-garage', 'pharmacy', 'pitch', 'place-of-worship', 'playground', 'police',
            'polling-place', 'post', 'prison', 'rail', 'rail-above', 'rail-light', 'rail-metro',
            'rail-underground', 'religious-christian', 'religious-jewish', 'religious-muslim',
            'restaurant', 'roadblock', 'rocket', 'school', 'scooter', 'shop', 'skiing', 'slaughterhouse',
            'soccer', 'square', 'square-stroked', 'star', 'star-stroked', 'suitcase', 'swimming',
            'telephone', 'tennis', 'theatre', 'toilets', 'town', 'town-hall', 'triangle', 'triangle-stroked',
            'village', 'warehouse', 'waste-basket', 'water', 'wetland', 'zoo'
        ) THEN REPLACE(type, '_', '-')
        ELSE NULL
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION rank_poi(type VARCHAR) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE
        WHEN type IN ('public_building', 'police', 'townhall', 'courthouse') THEN 10
        WHEN type IN ('stadium') THEN 90
        WHEN type IN ('hospital') THEN 100
        WHEN type IN ('zoo') THEN 200
        WHEN type IN ('university', 'school', 'college', 'kindergarten') THEN 300
        WHEN type IN ('park') THEN 350
        WHEN type IN ('supermarket', 'department_store') THEN 400
        WHEN type IN ('nature_reserve', 'swimming_area') THEN 500
        WHEN type IN ('attraction') THEN 600
        ELSE 1000
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

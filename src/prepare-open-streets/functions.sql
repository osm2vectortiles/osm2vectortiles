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

CREATE OR REPLACE FUNCTION rank_country(population INTEGER) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE
        WHEN population >= 250000000 THEN 1
        WHEN population >= 100000000 THEN 2
        WHEN population >= 50000000 THEN 3
        WHEN population >= 25000000 THEN 4
        WHEN population >= 10000000 THEN 5
        WHEN population < 10000000 THEN 6
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION rank_marine(type VARCHAR) RETURNS INTEGER
AS $$
BEGIN
    RETURN CASE
        WHEN type IN ('ocean') THEN 1
        WHEN type IN ('sea') THEN 3
        WHEN type IN ('bay') THEN 5
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

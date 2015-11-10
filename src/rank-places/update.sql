UPDATE osm_places
SET scalerank = improved_places.scalerank
FROM
(
    SELECT osm.osm_id, ne.scalerank
    FROM ne_cities AS ne, osm_places AS osm
    WHERE
        (ne.name LIKE osm.name OR ne.name LIKE osm.name_en)
        AND (osm.type = 'city' OR osm.type = 'town' OR osm.type = 'village')
        AND st_dwithin(ne.geom, osm.geometry, 50000)
) AS improved_places
WHERE osm_places.osm_id = improved_places.osm_id;

UPDATE osm_marine
SET scalerank = improved_seas.scalerank
FROM
(
    SELECT osm.osm_id, ne.scalerank
    FROM ne_110m_geography_marine_polys AS ne, osm_marine AS osm
    WHERE ne.name LIKE osm.name
) AS improved_seas
WHERE osm_marine.osm_id = improved_seas.osm_id;

UPDATE osm_countries
SET scalerank = improved_countries.scalerank
FROM
(
    SELECT osm.osm_id, ne.scalerank
    FROM ne_110m_admin_0_countries AS ne, osm_countries AS osm
    WHERE (ne.name LIKE osm.name OR ne.name LIKE osm.name_en)
) AS improved_countries
WHERE osm_countries.osm_id = improved_countries.osm_id;


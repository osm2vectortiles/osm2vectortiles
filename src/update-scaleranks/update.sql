UPDATE osm_place_point
SET scalerank = improved_places.scalerank
FROM
(
    SELECT osm.osm_id, ne.scalerank
    FROM ne_10m_populated_places AS ne, osm_place_point AS osm
    WHERE
    (
        ne.name ILIKE osm.name OR
        ne.name ILIKE osm.name_en OR
        ne.namealt ILIKE osm.name OR
        ne.namealt ILIKE osm.name_en
    )
    AND (osm.type = 'city' OR osm.type = 'town' OR osm.type = 'village')
    AND st_dwithin(ne.geom, osm.geometry, 50000)
    ) AS improved_places
WHERE osm_place_point.osm_id = improved_places.osm_id;

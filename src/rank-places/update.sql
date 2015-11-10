UPDATE osm_places
SET scalerank = improved_places.scalerank
FROM
(
    SELECT op.osm_id, nc.scalerank
    FROM ne_cities AS nc, osm_places AS op
    WHERE
        (nc.name = op.name OR nc.name = op.name_en)
        AND (op.type = 'city' OR op.type = 'town' OR op.type = 'village')
        AND st_dwithin(nc.geom, op.geometry, 50000)
) AS improved_places
WHERE osm_places.osm_id = improved_places.osm_id

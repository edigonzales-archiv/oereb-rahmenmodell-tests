WITH parcel AS 
(
  SELECT
    g.egris_egrid, 
    l.geometrie AS geometry
  FROM
    av_avdpool_ng.liegenschaften_grundstueck AS g 
    RIGHT JOIN av_avdpool_ng.liegenschaften_liegenschaft AS l 
    ON l.liegenschaft_von = g.t_id
  WHERE
    g.egris_egrid = 'CH870672603279'
),
restriction AS 
(
  SELECT 
--    ST_AsEWKT(flaeche_lv95),
  --  (ST_Dump(flaeche_lv95)).geom,
    *
  FROM
  (
    SELECT
      t_id,
      eigentumsbeschraenkung,
      flaeche_lv95,
      linie_lv95,
      punkt_lv95
    FROM
      agi_oereb_trsfr.transferstruktur_geometrie AS trsfr_geom,
      parcel
    WHERE 
      ST_Intersects(parcel.geometry, flaeche_lv95)  
      OR
      ST_Intersects(parcel.geometry, linie_lv95)  
      OR
      ST_Intersects(parcel.geometry, punkt_lv95)  
  ) AS eb_geom
  LEFT JOIN agi_oereb_trsfr.transferstruktur_eigentumsbeschraenkung AS eb
  ON eb_geom.eigentumsbeschraenkung = eb.t_id
)
SELECT 
  *
FROM 
  restriction
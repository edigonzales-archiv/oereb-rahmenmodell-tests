/*
WITH parcel AS 
(
  SELECT
    g.egris_egrid, 
    l.flaechenmass,
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
  eb_geom.t_id, 
  eb.t_id AS restriction_t_id,
  eb.aussage_de AS information,
  eb.thema AS theme,
  eb.subthema AS subtheme,
  CASE
    WHEN eb.rechtsstatus = 'inKraft' THEN 'inForce'
    ELSE 'runningModifications'
  END AS law_status,
  eb_geom.geometry
FROM
(
  SELECT
    t_id,
    eigentumsbeschraenkung,
    flaeche_lv95 AS geometry
  FROM
    agi_oereb_trsfr.transferstruktur_geometrie AS trsfr_geom,
    parcel
  WHERE 
    ST_Intersects(parcel.geometry, flaeche_lv95)  
) AS eb_geom
LEFT JOIN agi_oereb_trsfr.transferstruktur_eigentumsbeschraenkung AS eb
ON eb_geom.eigentumsbeschraenkung = eb.t_id
)
-- hier direkt Geometrie reinschreiben.
SELECT
  
  --ST_AsEWKT(ST_Intersection(parcel.geometry, restriction.geometry)),
  --ST_Intersection(parcel.geometry, restriction.geometry),
  
  parcel.geometry) AS g,
  ST_AsEWKT(parcel.geometry) AS g0,
  ST_AsEWKT(ST_Intersection(parcel.geometry, restriction.geometry)) AS g1,
  ST_AsEWKT((ST_Dump(ST_CollectionExtract(ST_Intersection(parcel.geometry, restriction.geometry), 3))).geom) AS geometry,
  -- case when area_share > 1 (wegen segmentierung o.ä) -> deckeln auf 1.
  
  --(ST_Dump(ST_Intersection(parcel.geometry, restriction.geometry))).geom,
  --ST_Area((ST_Dump(ST_Intersection(parcel.geometry, restriction.geometry))).geom),
  --round(((ST_Area((ST_Dump(ST_Intersection(parcel.geometry, restriction.geometry))).geom) / parcel.flaechenmass)::NUMERIC),1) ,
  restriction.t_id,
  restriction.restriction_t_id,
  restriction.information,
  restriction.theme,
  restriction.subtheme,
  restriction.law_status
FROM 
  restriction
  LEFT JOIN parcel
  ON ST_Intersects(parcel.geometry, restriction.geometry)
 ;
 */

/*
SELECT
  *
FROM
  agi_oereb_trsfr.transferstruktur_hinweisvorschrift AS hinweisvorschrift
  LEFT JOIN agi_oereb_trsfr.vorschriften_dokument AS dokument
  ON hinweisvorschrift.vorschrift_vorschriften_dokument = dokument.t_id
WHERE 
  hinweisvorschrift.eigentumsbeschraenkung = 18564
*/

/*
SELECT
  le.t_id,
  le.symbol,
  le.legendetext_de AS legend_text,
  le.artcode AS type_code,
  le.artcodeliste AS type_code_list,
  le.thema AS theme,
  le.subthema AS subtheme
FROM
  agi_oereb_trsfr.transferstruktur_eigentumsbeschraenkung AS eb 
  LEFT JOIN agi_oereb_trsfr.transferstruktur_darstellungsdienst AS ds 
  ON ds.t_id = eb.darstellungsdienst
  LEFT JOIN agi_oereb_trsfr.transferstruktur_legendeeintrag AS le 
  ON le.transfrstrkstllngsdnst_legende = ds.t_id
WHERE 
  eb.t_id = 18564
  AND
  eb.artcode = le.artcode
*/  
  
SELECT 
  RIGHT(legendetext_de, 2),
  *
FROM 
(
  SELECT 
    le.t_id,
    le.symbol, 
    le.legendetext_de, --AS legend_text, 
    le.legendetext_fr, --AS legend_text, 
    le.artcode AS type_code, 
    le.artcodeliste AS type_code_list, 
    le.thema AS theme, 
    le.subthema AS subtheme 
  FROM 
    agi_oereb_trsfr.transferstruktur_eigentumsbeschraenkung AS eb  
    LEFT JOIN agi_oereb_trsfr.transferstruktur_darstellungsdienst AS ds  
    ON ds.t_id = eb.darstellungsdienst 
    LEFT JOIN agi_oereb_trsfr.transferstruktur_legendeeintrag AS le  
    ON le.transfrstrkstllngsdnst_legende = ds.t_id 
  WHERE    
    eb.artcode = le.artcode
) AS foo

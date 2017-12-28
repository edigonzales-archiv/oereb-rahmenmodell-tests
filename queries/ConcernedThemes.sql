/*
SELECT
  st_asewkt(grund_geom.geometrie) AS geometry
FROM
(
  SELECT
    *
  FROM
    av_avdpool_ng.liegenschaften_grundstueck
  WHERE
    egris_egrid = 'CH340632730960'
) AS grundstueck
LEFT JOIN
(
    SELECT 
      geometrie AS geometrie, 
      liegenschaft_von AS grundstueck_fk 
    FROM 
      av_avdpool_ng.liegenschaften_liegenschaft 
    UNION ALL
    SELECT 
      geometrie AS geometrie,
      selbstrecht_von AS grundstueck_fk 
    FROM 
      av_avdpool_ng.liegenschaften_selbstrecht 
) AS grund_geom
ON grund_geom.grundstueck_fk = grundstueck.t_id;
*/

-- SRID=2056;POLYGON((2597820.225 1225721.039,2597898.017 1225756.288,2597917.47 1225713.36,2597917.861 1225713.54,2597936.502 1225672.275,2597858.084 1225637.867,2597820.225 1225721.039))

SELECT 
  itfcode AS t_id,
  CASE
    WHEN ilicode = 'Nutzungsplanung' THEN 'LandUsePlans'
    WHEN ilicode = 'ProjektierungszonenNationalstrassen' THEN 'MotorwaysProjectPlaningZones'
    WHEN ilicode = 'BaulinienNationalstrassen' THEN 'MotorwaysBuildingLines'
    WHEN ilicode = 'ProjektierungszonenEisenbahnanlagen' THEN 'RailwaysProjectPlanningZones'
    WHEN ilicode = 'BaulinienEisenbahnanlagen' THEN 'RailwaysBuildingLines'
    WHEN ilicode = 'ProjektierungszonenFlughafenanlagen' THEN 'AirportsProjectPlanningZones'
    WHEN ilicode = 'BaulinienFlughafenanlagen' THEN 'AirportsBuildingLines'
    WHEN ilicode = 'SicherheitszonenplanFlughafen' THEN 'AirportsSecurityZonePlans'
    WHEN ilicode = 'BelasteteStandorte' THEN 'ContaminatedSites'
    WHEN ilicode = 'BelasteteStandorteMilitaer' THEN 'ContaminatedMilitarySites'
    WHEN ilicode = 'BelasteteStandorteZivileFlugplaetze' THEN 'ContaminatedCivilAviationSites'
    WHEN ilicode = 'BelasteteStandorteOeffentlicherVerkehr' THEN 'ContaminatedPublicTransportSites'
    WHEN ilicode = 'Grundwasserschutzzonen' THEN 'GroundwaterProtectionZones'
    WHEN ilicode = 'Grundwasserschutzareale' THEN 'GroundwaterProtectionSites'
    WHEN ilicode = 'Laermemfindlichkeitsstufen' THEN 'NoiseSensitivityLevels'
    WHEN ilicode = 'Waldgrenzen' THEN 'ForestPerimeters'
    WHEN ilicode = 'Waldabstandslinien' THEN 'MotorwaysProjectPlaningZones'
    WHEN ilicode = 'WeiteresThema' THEN 'WeiteresThema'
  END AS theme,
  CASE 
    WHEN thema IS NULL THEN FALSE
    ELSE TRUE
  END AS concerned,
  thema_txt.titel_de
FROM
(
  SELECT DISTINCT
    th.itfcode,
    eb.thema,
    th.ilicode
  FROM
  (
    SELECT
      t_id,
      eigentumsbeschraenkung,
      flaeche_lv95,
      linie_lv95,
      punkt_lv95
    FROM
      agi_oereb_trsfr.transferstruktur_geometrie
    WHERE 
      ST_Intersects(ST_PolygonFromText('POLYGON((2597820.225 1225721.039,2597898.017 1225756.288,2597917.47 1225713.36,2597917.861 1225713.54,2597936.502 1225672.275,2597858.084 1225637.867,2597820.225 1225721.039))', 2056), flaeche_lv95)  
      OR
      ST_Intersects(ST_PolygonFromText('POLYGON((2597820.225 1225721.039,2597898.017 1225756.288,2597917.47 1225713.36,2597917.861 1225713.54,2597936.502 1225672.275,2597858.084 1225637.867,2597820.225 1225721.039))', 2056), linie_lv95)  
      OR
      ST_Intersects(ST_PolygonFromText('POLYGON((2597820.225 1225721.039,2597898.017 1225756.288,2597917.47 1225713.36,2597917.861 1225713.54,2597936.502 1225672.275,2597858.084 1225637.867,2597820.225 1225721.039))', 2056), punkt_lv95)  
  ) AS eb_geom
  LEFT JOIN agi_oereb_trsfr.transferstruktur_eigentumsbeschraenkung AS eb
  ON eb.t_id = eb_geom.eigentumsbeschraenkung
  RIGHT JOIN agi_oereb_trsfr.thema AS th
  ON eb.thema = th.ilicode
  ORDER BY th.itfcode
) AS themes
LEFT JOIN agi_oereb_trsfr.codelistentext_thematxt AS thema_txt
ON thema_txt.code = ilicode
;


DELETE FROM agi_oereb_app.egrid_parcel;

INSERT INTO agi_oereb_app.egrid_parcel
(
	geometrie,
	egrid,
	"number",
	identdn
)

SELECT
	l.geometrie AS geometrie,
	g.egris_egrid AS egrid,
	g.nummer AS "number",
	g.nbident AS identdn
FROM
	av_avdpool_ng.liegenschaften_grundstueck AS g 
	RIGHT JOIN av_avdpool_ng.liegenschaften_liegenschaft AS l 
	ON g.t_id = l.liegenschaft_von

UNION ALL 
	
SELECT
	s.geometrie AS geometrie,
	g.egris_egrid AS egrid,
	g.nummer AS "number",
	g.nbident AS identdn
FROM
	av_avdpool_ng.liegenschaften_grundstueck AS g 
	RIGHT JOIN av_avdpool_ng.liegenschaften_selbstrecht AS s
	ON g.t_id = s.selbstrecht_von
;


DELETE FROM agi_oereb_app.egrid_address;

-- Liegenschaften
INSERT INTO agi_oereb_app.egrid_address
(
	postalcode,
	localisation,
	housing_number,
	egrid,
	"number",
	identdn
)

SELECT
	plz.plz,
	lokname.atext AS localisation,
	gebein.hausnummer AS housing_number,
	--gebein.lage AS lage,
	parcels.egrid,
	parcels."number" AS "number",
	parcels.identdn
FROM
	av_avdpool_ng.gebaeudeadressen_gebaeudeeingang AS gebein
	LEFT JOIN av_avdpool_ng.gebaeudeadressen_lokalisation AS lok
	ON gebein.gebaeudeeingang_von = lok.t_id 
	LEFT JOIN av_avdpool_ng.gebaeudeadressen_lokalisationsname AS lokname 
	ON lokname.benannte = lok.t_id
	LEFT JOIN 
	(
		SELECT
			l.t_id AS t_id,
			g.egris_egrid AS egrid,
			g.nummer AS "number",
			g.nbident AS identdn,
			'RealEstate' AS "type",
			'SO' AS canton,
			l.t_datasetname::int AS fosnr,
			l.geometrie AS geometrie
		FROM
			av_avdpool_ng.liegenschaften_grundstueck AS g 
			RIGHT JOIN av_avdpool_ng.liegenschaften_liegenschaft AS l 
			ON g.t_id = l.liegenschaft_von
	) AS 
	parcels
	ON ST_Intersects(gebein.lage, parcels.geometrie)
	LEFT JOIN av_plzortschaft.plzortschaft_plz6 AS plz
	ON ST_Intersects(gebein.lage, plz.flaeche)
	
WHERE 
	gebein.hausnummer IS NOT NULL
	AND gebein.attributeprovisorisch = 'nein'
	AND lokname.atext IS NOT NULL -- TODO: verifiy this
	AND gebein.hausnummer IS NOT NULL -- TODO: verifiy this
;

-- SelbstRecht
INSERT INTO agi_oereb_app.egrid_address
(
	postalcode,
	localisation,
	housing_number,
	egrid,
	"number",
	identdn
)

SELECT
	plz.plz,
	lokname.atext AS localisation,
	gebein.hausnummer AS housing_number,
	--gebein.lage AS lage,
	parcels.egrid,
	parcels."number" AS "number",
	parcels.identdn
FROM
	av_avdpool_ng.gebaeudeadressen_gebaeudeeingang AS gebein
	LEFT JOIN av_avdpool_ng.gebaeudeadressen_lokalisation AS lok
	ON gebein.gebaeudeeingang_von = lok.t_id 
	LEFT JOIN av_avdpool_ng.gebaeudeadressen_lokalisationsname AS lokname 
	ON lokname.benannte = lok.t_id
	LEFT JOIN 
	(
		SELECT
			s.t_id AS t_id,
			g.egris_egrid AS egrid,
			g.nummer AS "number",
			g.nbident AS identdn,
			'Distinct_and_permanent_rights.BuildingRight' AS "type",
			'SO' AS canton,
			s.t_datasetname::int AS fosnr,
			s.geometrie AS geometrie
		FROM
			av_avdpool_ng.liegenschaften_grundstueck AS g 
			RIGHT JOIN av_avdpool_ng.liegenschaften_selbstrecht AS s
			ON g.t_id = s.selbstrecht_von
	) AS 
	parcels
	ON ST_Intersects(gebein.lage, parcels.geometrie)
	LEFT JOIN av_plzortschaft.plzortschaft_plz6 AS plz
	ON ST_Intersects(gebein.lage, plz.flaeche)
	
WHERE 
	gebein.hausnummer IS NOT NULL
	AND gebein.attributeprovisorisch = 'nein'
	AND lokname.atext IS NOT NULL -- TODO: verifiy this
	AND gebein.hausnummer IS NOT NULL -- TODO: verifiy this
	AND parcels."number" IS NOT NULL -- TODO: verifiy this
;
	



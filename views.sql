CREATE OR REPLACE VIEW av_avdpool_ng.v_oereb_real_estate AS

SELECT
	l.t_id AS t_id,
	g.egris_egrid AS egrid,
	g.nummer AS "number",
	g.nbident AS identnd,
	'RealEstate' AS "type",
	'SO' AS canton,
	l.t_datasetname::int AS fosnr,
	-- some more properties...
	l.geometrie AS geometrie
FROM
	av_avdpool_ng.liegenschaften_grundstueck AS g 
	RIGHT JOIN av_avdpool_ng.liegenschaften_liegenschaft AS l 
	ON g.t_id = l.liegenschaft_von

UNION ALL 
	
SELECT
	s.t_id AS t_id,
	g.egris_egrid AS egrid,
	g.nummer AS "number",
	g.nbident AS identnd,
	'Distinct_and_permanent_rights.BuildingRight' AS "type",
	'SO' AS canton,
	s.t_datasetname::int AS fosnr,
	-- some more properties...
	s.geometrie AS geometrie
FROM
	av_avdpool_ng.liegenschaften_grundstueck AS g 
	RIGHT JOIN av_avdpool_ng.liegenschaften_selbstrecht AS s
	ON g.t_id = s.selbstrecht_von;
	




CREATE OR REPLACE VIEW av_avdpool_ng.v_oereb_real_estate AS

SELECT
	l.t_id AS t_id,
	g.egris_egrid AS egrid,
	g.nummer AS "number",
	g.nbident AS identnd,
	'RealEstate' AS "type",
	'SO' AS canton,
	l.t_datasetname::int AS fosnr,
	-- some more properties...
	l.geometrie AS geometrie
FROM
	av_avdpool_ng.liegenschaften_grundstueck AS g 
	RIGHT JOIN av_avdpool_ng.liegenschaften_liegenschaft AS l 
	ON g.t_id = l.liegenschaft_von;

-- UNION ALL w/ SelbstRecht





CREATE OR REPLACE VIEW av_avdpool_ng.v_oereb_liegenschaften_liegenschaft AS

SELECT
	l.t_id AS t_id,
	g.egris_egrid AS egrid,
	g.nummer AS "number",
	g.nbident AS identnd,
	l.geometrie AS geometrie
FROM
	av_avdpool_ng.liegenschaften_grundstueck AS g 
	RIGHT JOIN av_avdpool_ng.liegenschaften_liegenschaft AS l 
	ON g.t_id = l.liegenschaft_von;


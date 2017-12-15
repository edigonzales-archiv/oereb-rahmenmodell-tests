-- We need an "Publikationsmodell" for this!

CREATE ROLE oereb_read WITH LOGIN ENCRYPTED PASSWORD 'itstheendoftheworldasweknowit';

CREATE SCHEMA agi_oereb_app;
GRANT USAGE ON SCHEMA agi_oereb_app TO oereb_read;

CREATE TABLE agi_oereb_app.egrid_parcel (
	t_id bigserial,
	geometrie geometry(Polygon,2056) NOT NULL,
	egrid varchar(14) NOT NULL, 
	"number" varchar(12) NOT NULL,
	identdn varchar(12) NOT NULL,
    CONSTRAINT egrid_parcel_pkey PRIMARY KEY (t_id)
)
WITH (
	OIDS=FALSE
);

CREATE
    INDEX egrid_parcel_postalcode_idx ON
    agi_oereb_app.egrid_parcel
        USING gist(geometrie) ;


CREATE TABLE agi_oereb_app.egrid_address (
	t_id bigserial,
	postalcode int4 NOT NULL,
	localisation varchar(60) NOT NULL,
	housing_number varchar(12) NOT NULL,
	egrid varchar(14) NOT NULL,
	"number" varchar(12) NOT NULL,
	identdn varchar(12) NOT NULL,
    CONSTRAINT egrid_address_pkey PRIMARY KEY (t_id)
)
WITH (
	OIDS=FALSE
);

CREATE
    INDEX egrid_address_postalcode_idx ON
    agi_oereb_app.egrid_address
        USING btree(postalcode) ;

CREATE
    INDEX egrid_address_localisation_idx ON
    agi_oereb_app.egrid_address
        USING btree(localisation) ;

CREATE
    INDEX egrid_address_housing_number_idx ON
    agi_oereb_app.egrid_address
        USING btree(housing_number) ;

GRANT SELECT ON ALL TABLES IN SCHEMA agi_oereb_app TO oereb_read;



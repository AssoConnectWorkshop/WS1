-- ----------------------------------------------------------
-- MDB Tools - A library for reading MS Access database files
-- Copyright (C) 2000-2011 Brian Bruns and others.
-- Files in libmdb are licensed under LGPL and the utilities under
-- the GPL, see COPYING.LIB and COPYING files respectively.
-- Check out http://mdbtools.sourceforge.net
-- ----------------------------------------------------------

SET client_encoding = 'UTF-8';

CREATE TABLE IF NOT EXISTS "aimporter"
 (
	"n°"			SERIAL, 
	"codsit"			VARCHAR (255), 
	"f3"			VARCHAR (255), 
	"numcli"			DOUBLE PRECISION, 
	"nomsit"			VARCHAR (255), 
	"adrsit"			VARCHAR (255), 
	"codpossit"			DOUBLE PRECISION, 
	"vilsit"			VARCHAR (255), 
	"nbrentsit"			DOUBLE PRECISION, 
	"nbrvistecsit"			DOUBLE PRECISION, 
	"codint"			VARCHAR (255), 
	"mntredev"			VARCHAR (255), 
	"comsit"			VARCHAR (255)
);

-- CREATE INDEXES ...
CREATE INDEX "aimporter_numcli_idx" ON "aimporter" ("numcli");
ALTER TABLE "aimporter" ADD CONSTRAINT "aimporter_pkey" PRIMARY KEY ("n°");

CREATE TABLE IF NOT EXISTS "annuaire"
 (
	"ac"			VARCHAR (255), 
	"n°"			DOUBLE PRECISION, 
	"magasin"			VARCHAR (255), 
	"h/f"			VARCHAR (255), 
	"adresse"			VARCHAR (255), 
	"code_postal"			DOUBLE PRECISION, 
	"ville"			VARCHAR (255), 
	"f8"			VARCHAR (255), 
	"directrice"			VARCHAR (255), 
	"téléphone"			VARCHAR (255), 
	"abr# tél"			DOUBLE PRECISION, 
	"fax"			VARCHAR (255), 
	"abr# fax"			DOUBLE PRECISION
);

-- CREATE INDEXES ...
CREATE INDEX "annuaire_code_postal_idx" ON "annuaire" ("code_postal");
CREATE INDEX "annuaire_n°_idx" ON "annuaire" ("n°");

CREATE TABLE IF NOT EXISTS "auditclimatisation"
 (
);

-- CREATE INDEXES ...

CREATE TABLE IF NOT EXISTS "clientrma2"
 (
	"n°"			SERIAL, 
	"client"			VARCHAR (255), 
	"n° client interne"			DOUBLE PRECISION, 
	"n° compteur site"			DOUBLE PRECISION, 
	"n° site"			DOUBLE PRECISION, 
	"champ7"			VARCHAR (255), 
	"code site"			INTEGER, 
	"nom site"			VARCHAR (255), 
	"situation"			VARCHAR (255), 
	"champ9"			VARCHAR (255), 
	"adresse"			VARCHAR (255), 
	"cp"			INTEGER, 
	"ville"			VARCHAR (255), 
	"téléphone"			VARCHAR (255), 
	"fax"			VARCHAR (255), 
	"civilité"			VARCHAR (255), 
	"nom responsable"			VARCHAR (255), 
	"prénom responsable"			VARCHAR (255), 
	"zone géo"			DOUBLE PRECISION, 
	"surface vente"			DOUBLE PRECISION, 
	"surface totale"			DOUBLE PRECISION, 
	"nbre entretien"			DOUBLE PRECISION, 
	"nbrdesenfsit"			INTEGER, 
	"date dernière visite désenfumage"			VARCHAR (255), 
	"commentaire"			VARCHAR (255), 
	"tél centre commercial"			VARCHAR (255), 
	"date création du site"			VARCHAR (255), 
	"montant redevance"			NUMERIC(15,2), 
	"indicateur qualité"			DOUBLE PRECISION, 
	"indicateur vetusté"			DOUBLE PRECISION, 
	"indicateur puissance"			DOUBLE PRECISION, 
	"indicateur accessibilité"			DOUBLE PRECISION, 
	"date prise en charge"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_lun_ouv"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_lun_fer"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_mar_ouv"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_mar_fer"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_mer_ouv"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_mer_fer"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_jeu_ouv"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_jeu_fer"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_ven_ouv"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_ven_fer"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_sam_ouv"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_sam_fer"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_dim_ouv"			VARCHAR (255), 
	"hor_dim_fer"			VARCHAR (255), 
	"type de fluide"			VARCHAR (255), 
	"t° entrée"			VARCHAR (255), 
	"t° sortie"			VARCHAR (255), 
	"champ50"			VARCHAR (255), 
	"code intervenant"			VARCHAR (255), 
	"créée le"			TIMESTAMP WITHOUT TIME ZONE, 
	"date de mise à jour"			TIMESTAMP WITHOUT TIME ZONE, 
	"longitude"			DOUBLE PRECISION, 
	"latitude"			DOUBLE PRECISION, 
	"date 1er maintenance"			TIMESTAMP WITHOUT TIME ZONE, 
	"lien vers fiche d'inter"			VARCHAR (255), 
	"date derniere visite desemfumage"			VARCHAR (255), 
	"lien vers fiche d'inter 1"			VARCHAR (255), 
	"intervenant"			VARCHAR (255), 
	"entreprise referante"			VARCHAR (255)
);

-- CREATE INDEXES ...
CREATE INDEX "clientrma2_code intervenant_idx" ON "clientrma2" ("code intervenant");
CREATE INDEX "clientrma2_code site_idx" ON "clientrma2" ("code site");
CREATE INDEX "clientrma2_n° client interne_idx" ON "clientrma2" ("n° client interne");
CREATE INDEX "clientrma2_n° compteur site_idx" ON "clientrma2" ("n° compteur site");
CREATE INDEX "clientrma2_n° site_idx" ON "clientrma2" ("n° site");
ALTER TABLE "clientrma2" ADD CONSTRAINT "clientrma2_pkey" PRIMARY KEY ("n°");

CREATE TABLE IF NOT EXISTS "clientscelio"
 (
	"id"			SERIAL, 
	"client"			VARCHAR (255), 
	"n° client interne"			DOUBLE PRECISION, 
	"n° compteur site"			DOUBLE PRECISION, 
	"n° site"			DOUBLE PRECISION, 
	"champ7"			VARCHAR (255), 
	"code site"			VARCHAR (255), 
	"nom site"			VARCHAR (255), 
	"situation"			VARCHAR (255), 
	"champ9"			VARCHAR (255), 
	"adresse"			VARCHAR (255), 
	"cp"			VARCHAR (255), 
	"ville"			VARCHAR (255), 
	"téléphone"			VARCHAR (255), 
	"fax"			VARCHAR (255), 
	"civilité"			VARCHAR (255), 
	"nom responsable"			VARCHAR (255), 
	"prénom responsable"			VARCHAR (255), 
	"zone géo"			DOUBLE PRECISION, 
	"surface vente"			DOUBLE PRECISION, 
	"surface totale"			DOUBLE PRECISION, 
	"nbre entretien"			DOUBLE PRECISION, 
	"nbrdesenfsit"			VARCHAR (255), 
	"date dernière visite désenfumage"			VARCHAR (255), 
	"commentaire"			VARCHAR (255), 
	"tél centre commercial"			VARCHAR (255), 
	"date création du site"			VARCHAR (255), 
	"montant redevance"			DOUBLE PRECISION, 
	"indicateur qualité"			DOUBLE PRECISION, 
	"indicateur vetusté"			DOUBLE PRECISION, 
	"indicateur puissance"			DOUBLE PRECISION, 
	"indicateur accessibilité"			DOUBLE PRECISION, 
	"date prise en charge"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_lun_ouv"			VARCHAR (255), 
	"hor_lun_fer"			VARCHAR (255), 
	"hor_mar_ouv"			VARCHAR (255), 
	"hor_mar_fer"			VARCHAR (255), 
	"hor_mer_ouv"			VARCHAR (255), 
	"hor_mer_fer"			VARCHAR (255), 
	"hor_jeu_ouv"			VARCHAR (255), 
	"hor_jeu_fer"			VARCHAR (255), 
	"hor_ven_ouv"			VARCHAR (255), 
	"hor_ven_fer"			VARCHAR (255), 
	"hor_sam_ouv"			VARCHAR (255), 
	"hor_sam_fer"			VARCHAR (255), 
	"hor_dim_ouv"			VARCHAR (255), 
	"hor_dim_fer"			VARCHAR (255), 
	"type de fluide"			DOUBLE PRECISION, 
	"t° entrée"			VARCHAR (255), 
	"t° sortie"			VARCHAR (255), 
	"champ50"			VARCHAR (255), 
	"code intervenant"			DOUBLE PRECISION, 
	"créée le"			TIMESTAMP WITHOUT TIME ZONE, 
	"date de mise à jour"			TIMESTAMP WITHOUT TIME ZONE, 
	"longitude"			DOUBLE PRECISION, 
	"latitude"			DOUBLE PRECISION
);

-- CREATE INDEXES ...
CREATE INDEX "clientscelio_code intervenant_idx" ON "clientscelio" ("code intervenant");
CREATE INDEX "clientscelio_code site_idx" ON "clientscelio" ("code site");
ALTER TABLE "clientscelio" ADD CONSTRAINT "clientscelio_pkey" PRIMARY KEY ("id");
CREATE INDEX "clientscelio_n° client interne_idx" ON "clientscelio" ("n° client interne");
CREATE INDEX "clientscelio_n° compteur site_idx" ON "clientscelio" ("n° compteur site");
CREATE INDEX "clientscelio_n° site_idx" ON "clientscelio" ("n° site");

CREATE TABLE IF NOT EXISTS "import"
 (
	"donneur d'ordre"			INTEGER, 
	"nom intervenant"			INTEGER, 
	"champ3"			VARCHAR (255), 
	"champ4"			DOUBLE PRECISION, 
	"client"			VARCHAR (255), 
	"n° site"			VARCHAR (255), 
	"champ7"			VARCHAR (255), 
	"champ8"			VARCHAR (255), 
	"champ9"			VARCHAR (255), 
	"champ10"			VARCHAR (255), 
	"nom du site"			VARCHAR (255), 
	"pour devis sav"			VARCHAR (255), 
	"indicateur"			VARCHAR (255), 
	"a service le"			VARCHAR (255), 
	"adresse"			VARCHAR (255), 
	"cp"			VARCHAR (255), 
	"ville"			VARCHAR (255), 
	"telephone"			VARCHAR (255), 
	"fax"			VARCHAR (255), 
	"situation"			VARCHAR (255), 
	"mail"			VARCHAR (255), 
	"nom responsable"			VARCHAR (255), 
	"zone d'intervention"			INTEGER, 
	"champ24"			VARCHAR (255), 
	"champ25"			VARCHAR (255), 
	"n° contrat (maintenance)"			VARCHAR (255), 
	"nombre d'entretien annuel (maintenance)"			INTEGER
);

-- CREATE INDEXES ...
CREATE INDEX "import_n° contrat (maintenance)_idx" ON "import" ("n° contrat (maintenance)");
CREATE INDEX "import_n° site_idx" ON "import" ("n° site");

CREATE TABLE IF NOT EXISTS "importrma"
 (
	"n°"			SERIAL, 
	"client"			VARCHAR (255), 
	"n° client interne"			DOUBLE PRECISION, 
	"n° compteur site"			DOUBLE PRECISION, 
	"n° site"			DOUBLE PRECISION, 
	"code site"			INTEGER, 
	"nom site"			VARCHAR (255), 
	"situation"			VARCHAR (255), 
	"adresse"			VARCHAR (255), 
	"cp"			VARCHAR (10), 
	"ville"			VARCHAR (255), 
	"téléphone"			VARCHAR (255), 
	"fax"			VARCHAR (255), 
	"civilité"			VARCHAR (255), 
	"nom responsable"			VARCHAR (255), 
	"prénom responsable"			VARCHAR (255), 
	"zone géo"			DOUBLE PRECISION, 
	"surface vente"			DOUBLE PRECISION, 
	"surface totale"			DOUBLE PRECISION, 
	"nbre entretien"			DOUBLE PRECISION, 
	"nbrdesenfsit"			INTEGER, 
	"date dernière visite désenfumage"			VARCHAR (255), 
	"commentaire"			VARCHAR (255), 
	"tél centre commercial"			VARCHAR (255), 
	"date création du site"			VARCHAR (255), 
	"montant redevance"			NUMERIC(15,2), 
	"indicateur qualité"			DOUBLE PRECISION, 
	"indicateur vetusté"			DOUBLE PRECISION, 
	"indicateur puissance"			DOUBLE PRECISION, 
	"indicateur accessibilité"			DOUBLE PRECISION, 
	"date prise en charge"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_lun_ouv"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_lun_fer"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_mar_ouv"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_mar_fer"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_mer_ouv"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_mer_fer"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_jeu_ouv"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_jeu_fer"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_ven_ouv"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_ven_fer"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_sam_ouv"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_sam_fer"			TIMESTAMP WITHOUT TIME ZONE, 
	"hor_dim_ouv"			VARCHAR (255), 
	"hor_dim_fer"			VARCHAR (255), 
	"type de fluide"			VARCHAR (255), 
	"t° entrée"			VARCHAR (255), 
	"t° sortie"			VARCHAR (255), 
	"champ50"			VARCHAR (255), 
	"code intervenant"			VARCHAR (255), 
	"créée le"			TIMESTAMP WITHOUT TIME ZONE, 
	"date de mise à jour"			TIMESTAMP WITHOUT TIME ZONE, 
	"longitude"			DOUBLE PRECISION, 
	"latitude"			DOUBLE PRECISION, 
	"date 1er maintenance"			TIMESTAMP WITHOUT TIME ZONE, 
	"lien vers fiche d'inter"			VARCHAR (255), 
	"date derniere visite desemfumage"			VARCHAR (255), 
	"lien vers fiche d'inter 1"			VARCHAR (255), 
	"intervenant"			VARCHAR (255), 
	"entreprise referante"			VARCHAR (255), 
	"intervenant1"			VARCHAR (255), 
	"entreprise referante1"			VARCHAR (255)
);

-- CREATE INDEXES ...
CREATE INDEX "importrma_code intervenant_idx" ON "importrma" ("code intervenant");
CREATE INDEX "importrma_code site_idx" ON "importrma" ("code site");
CREATE INDEX "importrma_n° client interne_idx" ON "importrma" ("n° client interne");
CREATE INDEX "importrma_n° compteur site_idx" ON "importrma" ("n° compteur site");
CREATE INDEX "importrma_n° site_idx" ON "importrma" ("n° site");
ALTER TABLE "importrma" ADD CONSTRAINT "importrma_pkey" PRIMARY KEY ("n°");

CREATE TABLE IF NOT EXISTS "importsas"
 (
	"numcli"			INTEGER, 
	"codsit"			VARCHAR (255), 
	"nomsit"			VARCHAR (255), 
	"adrsit"			VARCHAR (255), 
	"codpossit"			VARCHAR (255), 
	"vilsit"			VARCHAR (255), 
	"telsit"			VARCHAR (255), 
	"nbrentvis"			INTEGER, 
	"donneurid"			INTEGER, 
	"cptsit"			SERIAL
);

-- CREATE INDEXES ...
CREATE INDEX "importsas_numcli_idx" ON "importsas" ("numcli");
ALTER TABLE "importsas" ADD CONSTRAINT "importsas_pkey" PRIMARY KEY ("cptsit");

CREATE TABLE IF NOT EXISTS "impplanning"
 (
	"nomint"			VARCHAR (50), 
	"numclient"			INTEGER, 
	"nomclient"			VARCHAR (50), 
	"numsite"			INTEGER, 
	"nomsite"			VARCHAR (50), 
	"typesite"			VARCHAR (50), 
	"nbvisite"			INTEGER, 
	"m1"			VARCHAR (50), 
	"m2"			VARCHAR (50), 
	"m3"			VARCHAR (50), 
	"m4"			VARCHAR (50), 
	"m5"			VARCHAR (50), 
	"m6"			VARCHAR (50), 
	"m7"			VARCHAR (50), 
	"m8"			VARCHAR (50), 
	"m9"			VARCHAR (50), 
	"m10"			VARCHAR (50), 
	"m11"			VARCHAR (50), 
	"m12"			VARCHAR (50)
);

-- CREATE INDEXES ...
CREATE INDEX "impplanning_numclient_idx" ON "impplanning" ("numclient");
CREATE INDEX "impplanning_numsite_idx" ON "impplanning" ("numsite");

CREATE TABLE IF NOT EXISTS "parametre"
 (
	"numpar"			SERIAL, 
	"numcli"			INTEGER, 
	"datdeb"			TIMESTAMP WITHOUT TIME ZONE, 
	"datfin"			TIMESTAMP WITHOUT TIME ZONE, 
	"datfinpla"			TIMESTAMP WITHOUT TIME ZONE
);

-- CREATE INDEXES ...
CREATE INDEX "parametre_numcli_idx" ON "parametre" ("numcli");
CREATE INDEX "parametre_numpar_idx" ON "parametre" ("numpar");

CREATE TABLE IF NOT EXISTS "planning"
 (
	"numsit"			INTEGER, 
	"semaine 1"			VARCHAR (50), 
	"semaine 2"			VARCHAR (50), 
	"semaine 3"			VARCHAR (50), 
	"semaine 4"			VARCHAR (50), 
	"semaine 5"			VARCHAR (50), 
	"semaine 6"			VARCHAR (50), 
	"semaine 7"			VARCHAR (50), 
	"semaine 8"			VARCHAR (50), 
	"semaine 9"			VARCHAR (50), 
	"semaine 10"			VARCHAR (50), 
	"semaine 11"			VARCHAR (50), 
	"semaine 12"			VARCHAR (50), 
	"semaine 13"			VARCHAR (50), 
	"semaine 14"			VARCHAR (50), 
	"semaine 15"			VARCHAR (50), 
	"semaine 16"			VARCHAR (50), 
	"semaine 17"			VARCHAR (50), 
	"semaine 18"			VARCHAR (50), 
	"semaine 19"			VARCHAR (50), 
	"semaine 20"			VARCHAR (50), 
	"semaine 21"			VARCHAR (50), 
	"semaine 22"			VARCHAR (50), 
	"semaine 23"			VARCHAR (50), 
	"semaine 24"			VARCHAR (50), 
	"semaine 25"			VARCHAR (50), 
	"semaine 26"			VARCHAR (50), 
	"semaine 27"			VARCHAR (50), 
	"semaine 28"			VARCHAR (50), 
	"semaine 29"			VARCHAR (50), 
	"semaine 30"			VARCHAR (50), 
	"semaine 31"			VARCHAR (50), 
	"semaine 32"			VARCHAR (50), 
	"semaine 33"			VARCHAR (50), 
	"semaine 34"			VARCHAR (50), 
	"semaine 35"			VARCHAR (50), 
	"semaine 36"			VARCHAR (50), 
	"semaine 37"			VARCHAR (50), 
	"semaine 38"			VARCHAR (50), 
	"semaine 39"			VARCHAR (50), 
	"semaine 40"			VARCHAR (50), 
	"semaine 41"			VARCHAR (50), 
	"semaine 42"			VARCHAR (50), 
	"semaine 43"			VARCHAR (50), 
	"semaine 44"			VARCHAR (50), 
	"semaine 45"			VARCHAR (50), 
	"semaine 46"			VARCHAR (50), 
	"semaine 47"			VARCHAR (50), 
	"semaine 48"			VARCHAR (50), 
	"semaine 49"			VARCHAR (50), 
	"semaine 50"			VARCHAR (50), 
	"semaine 51"			VARCHAR (50), 
	"semaine 52"			VARCHAR (50)
);

-- CREATE INDEXES ...
ALTER TABLE "planning" ADD CONSTRAINT "planning_pkey" PRIMARY KEY ("numsit");

CREATE TABLE IF NOT EXISTS "switchboard items"
 (
	"switchboardid"			INTEGER, 
	"itemnumber"			INTEGER, 
	"itemtext"			VARCHAR (255), 
	"command"			INTEGER, 
	"argument"			VARCHAR (255)
);

-- CREATE INDEXES ...
ALTER TABLE "switchboard items" ADD CONSTRAINT "switchboard items_pkey" PRIMARY KEY ("switchboardid", "itemnumber");

CREATE TABLE IF NOT EXISTS "table des erreurs"
 (
	"champ0"			TEXT, 
	"champ1"			TEXT, 
	"champ2"			TEXT, 
	"champ3"			TEXT, 
	"champ4"			TEXT, 
	"champ5"			TEXT, 
	"champ6"			TEXT, 
	"champ7"			TEXT, 
	"champ8"			TEXT
);

-- CREATE INDEXES ...

CREATE TABLE IF NOT EXISTS "audit"
 (
);

-- CREATE INDEXES ...


-- CREATE Relationships ...
-- relationships are not implemented for postgres

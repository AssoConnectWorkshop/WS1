-- logiclim.dbo.Activites definition

-- Drop table

-- DROP TABLE logiclim.dbo.Activites;

CREATE TABLE logiclim.dbo.Activites (
	Numactivite int IDENTITY(1,1) NOT NULL,
	Nomactivite nchar(51) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_Activites PRIMARY KEY (Numactivite)
);


-- logiclim.dbo.Audit definition

-- Drop table

-- DROP TABLE logiclim.dbo.Audit;

CREATE TABLE logiclim.dbo.Audit (
	numaudit int IDENTITY(1,1) NOT NULL,
	numcli int NULL,
	cptsit int NULL,
	dateaudit date NULL,
	panopliehydraulique bit DEFAULT 0 NOT NULL,
	boucleeautemperatureconstante bit DEFAULT 0 NOT NULL,
	eauglacee bit DEFAULT 0 NOT NULL,
	eauperdue bit DEFAULT 0 NOT NULL,
	vannereglagetypeTA bit DEFAULT 0 NOT NULL,
	potantiboue bit DEFAULT 0 NOT NULL,
	filtresaeau bit DEFAULT 0 NOT NULL,
	manometre bit DEFAULT 0 NOT NULL,
	thermometre bit DEFAULT 0 NOT NULL,
	purgeur bit DEFAULT 0 NOT NULL,
	bypass bit DEFAULT 0 NOT NULL,
	electrovanne bit DEFAULT 0 NOT NULL,
	vannepressostatique bit DEFAULT 0 NOT NULL,
	observationspanopliehydraulique varchar(MAX) COLLATE French_CI_AS NULL,
	observationsregulationcommande varchar(MAX) COLLATE French_CI_AS NULL,
	observationsliaisonsfrigorifiques varchar(MAX) COLLATE French_CI_AS NULL,
	coupureproximiteqte int NULL,
	coupureproximiteetat tinyint NULL,
	coupureproximitelocalisation varchar(100) COLLATE French_CI_AS NULL,
	coupureproximiteobservations varchar(MAX) COLLATE French_CI_AS NULL,
	condensatpompederelevagemarque nvarchar(50) COLLATE French_CI_AS NULL,
	condensatpompederelevagetype nvarchar(50) COLLATE French_CI_AS NULL,
	condensatpompederelevageemplacement nvarchar(50) COLLATE French_CI_AS NULL,
	condensatpvc bit DEFAULT 0 NOT NULL,
	condensatsouple bit DEFAULT 0 NOT NULL,
	condensatpvcdiametre real NULL,
	condensatsouplediametre real NULL,
	condensatetat tinyint NULL,
	condensatraccordementeu bit DEFAULT 0 NOT NULL,
	condensatraccordementep bit DEFAULT 0 NOT NULL,
	condensatraccordementext bit DEFAULT 0 NOT NULL,
	condensatcheminementsurfacedevente bit DEFAULT 0 NOT NULL,
	condensatcheminementreserve bit DEFAULT 0 NOT NULL,
	condensatcheminementtoiture bit DEFAULT 0 NOT NULL,
	condensatcheminementtremie bit DEFAULT 0 NOT NULL,
	condensatobservations varchar(MAX) COLLATE French_CI_AS NULL,
	lotaerauliquediffuseurcirculaire bit DEFAULT 0 NOT NULL,
	lotaerauliquediffuseurcarre bit DEFAULT 0 NOT NULL,
	lotaerauliquebuselongueportee bit DEFAULT 0 NOT NULL,
	lotaerauliquediffuseurcirculaireqte real NULL,
	lotaerauliquediffuseurcarreqte real NULL,
	lotaerauliquebuselongueporteeqte real NULL,
	lotaerauliquegainetextile bit DEFAULT 0 NOT NULL,
	lotaerauliquegainesouple bit DEFAULT 0 NOT NULL,
	lotaerauliquegalvacirculaire bit DEFAULT 0 NOT NULL,
	lotaerauliquegalvacirculairecalorifugee bit DEFAULT 0 NOT NULL,
	lotaerauliquegalvarectangulaire bit DEFAULT 0 NOT NULL,
	lotaerauliquegalvarectangulairecalorifugee bit DEFAULT 0 NOT NULL,
	lotaerauliquereprisegrilletrape bit DEFAULT 0 NOT NULL,
	lotaerauliquereprisegrilletrapeqte real NULL,
	lotaerauliquerepriseautres varchar(MAX) COLLATE French_CI_AS NULL,
	lotaerauliqueobservations varchar(MAX) COLLATE French_CI_AS NULL,
	rooftopobservations varchar(MAX) COLLATE French_CI_AS NULL,
	rideauairchaudobservations varchar(MAX) COLLATE French_CI_AS NULL,
	aerothermeobservations varchar(MAX) COLLATE French_CI_AS NULL,
	photosarealiserfacade bit DEFAULT 0 NULL,
	photoarealisertoiture bit DEFAULT 0 NULL,
	photoarealiseruniteinterieure bit DEFAULT 0 NULL,
	photoarealiseruniteexterieure bit DEFAULT 0 NULL,
	photoarealiserplan bit DEFAULT 0 NULL,
	photoarealisertableauelectrique bit DEFAULT 0 NULL,
	photoarealiservueensemble bit DEFAULT 0 NULL,
	CONSTRAINT PK_Audit PRIMARY KEY (numaudit)
);


-- logiclim.dbo.AuditAerotherme definition

-- Drop table

-- DROP TABLE logiclim.dbo.AuditAerotherme;

CREATE TABLE logiclim.dbo.AuditAerotherme (
	numeroauditaerotherme int IDENTITY(1,1) NOT NULL,
	numaudit int NOT NULL,
	Marque nvarchar(50) COLLATE French_CI_AS NULL,
	Reference nvarchar(50) COLLATE French_CI_AS NULL,
	NumeroSerie nvarchar(50) COLLATE French_CI_AS NULL,
	TypeGaz bit DEFAULT 0 NOT NULL,
	TypeElectrique bit DEFAULT 0 NOT NULL,
	CONSTRAINT PK_AuditAerotherme PRIMARY KEY (numeroauditaerotherme)
);


-- logiclim.dbo.AuditClimatisation definition

-- Drop table

-- DROP TABLE logiclim.dbo.AuditClimatisation;

CREATE TABLE logiclim.dbo.AuditClimatisation (
	numaudit int NOT NULL,
	numauditclimatisation int IDENTITY(1,1) NOT NULL,
	Marque nvarchar(50) COLLATE French_CI_AS NULL,
	Reference nvarchar(50) COLLATE French_CI_AS NULL,
	NumeroSerie nvarchar(50) COLLATE French_CI_AS NULL,
	[Type] nvarchar(50) COLLATE French_CI_AS NULL,
	FluideQuantite nvarchar(50) COLLATE French_CI_AS NULL,
	AccessibiliteGroupe nvarchar(50) COLLATE French_CI_AS NULL,
	AccessibiliteCassettes nvarchar(50) COLLATE French_CI_AS NULL,
	Emplacement nvarchar(50) COLLATE French_CI_AS NULL,
	Etat tinyint NULL,
	Observations nvarchar(MAX) COLLATE French_CI_AS NULL,
	NumeroSiteMateriel int NULL,
	CONSTRAINT PK_AuditClimatisation PRIMARY KEY (numauditclimatisation)
);


-- logiclim.dbo.AuditRegulationCommande definition

-- Drop table

-- DROP TABLE logiclim.dbo.AuditRegulationCommande;

CREATE TABLE logiclim.dbo.AuditRegulationCommande (
	numeroregulationcommande int IDENTITY(1,1) NOT NULL,
	numaudit int NULL,
	TypeTelecommande nchar(20) COLLATE French_CI_AS NULL,
	NbreTelecommande tinyint NULL,
	EmplacementTelecommande nvarchar(50) COLLATE French_CI_AS NULL,
	EtatTelecommande tinyint NULL,
	HauteurTelecommande real NULL,
	CONSTRAINT PK_AuditRegulationCommande PRIMARY KEY (numeroregulationcommande)
);


-- logiclim.dbo.AuditRoofTop definition

-- Drop table

-- DROP TABLE logiclim.dbo.AuditRoofTop;

CREATE TABLE logiclim.dbo.AuditRoofTop (
	numeroauditrooftop int IDENTITY(1,1) NOT NULL,
	numaudit int NOT NULL,
	numcli int NULL,
	cptsit int NULL,
	typeelectrique bit DEFAULT 0 NOT NULL,
	typegaz bit DEFAULT 0 NOT NULL,
	typereversible bit NOT NULL,
	Marque nvarchar(50) COLLATE French_CI_AS NULL,
	Reference nvarchar(50) COLLATE French_CI_AS NULL,
	NumeroSerie nvarchar(50) COLLATE French_CI_AS NULL,
	NombreTotalFiltres tinyint NULL,
	FiltrationTypeG3 bit DEFAULT 0 NOT NULL,
	FiltrationTypeG4 bit DEFAULT 0 NOT NULL,
	FiltrationTypeAutre bit DEFAULT 0 NOT NULL,
	DimensionH1 real NULL,
	DimensionL1 real NULL,
	DimensionP1 real NULL,
	DimensionQte1 tinyint NULL,
	DimensionH2 real NULL,
	DimensionL2 real NULL,
	DimensionP2 real NULL,
	DimensionQte2 tinyint NULL,
	DimensionH3 real NULL,
	DimensionL3 real NULL,
	DimensionP3 real NULL,
	DimensionQte3 tinyint NULL,
	CourroieNombre tinyint NULL,
	CourroieType varchar(50) COLLATE French_CI_AS NULL,
	CourroieDimensions varchar(50) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_AuditRoofTop PRIMARY KEY (numeroauditrooftop)
);


-- logiclim.dbo.C16 definition

-- Drop table

-- DROP TABLE logiclim.dbo.C16;

CREATE TABLE logiclim.dbo.C16 (
	numcli int NULL,
	cptsit int NULL,
	Agence nvarchar(255) COLLATE French_CI_AS NULL,
	Adresse nvarchar(255) COLLATE French_CI_AS NULL,
	CP float NULL,
	VILLE nvarchar(255) COLLATE French_CI_AS NULL,
	[N° agence] float NULL,
	[N° installation] float NULL,
	[Désignation matériel] nvarchar(255) COLLATE French_CI_AS NULL,
	Localisation nvarchar(255) COLLATE French_CI_AS NULL,
	Marque nvarchar(255) COLLATE French_CI_AS NULL,
	[Type - Modèle] nvarchar(255) COLLATE French_CI_AS NULL,
	[N° série ] float NULL,
	[Puissance  / Capacité] nvarchar(255) COLLATE French_CI_AS NULL,
	Commentaires nvarchar(255) COLLATE French_CI_AS NULL
);


-- logiclim.dbo.C24 definition

-- Drop table

-- DROP TABLE logiclim.dbo.C24;

CREATE TABLE logiclim.dbo.C24 (
	cptsit int NULL,
	numcli int NULL,
	AGENCE nvarchar(255) COLLATE French_CI_AS NULL,
	ADRESSE nvarchar(255) COLLATE French_CI_AS NULL,
	CP float NULL,
	VILLE nvarchar(255) COLLATE French_CI_AS NULL,
	[N° Installation] float NULL,
	[Désignation matériel] nvarchar(255) COLLATE French_CI_AS NULL,
	Marque nvarchar(255) COLLATE French_CI_AS NULL,
	[Type] nvarchar(255) COLLATE French_CI_AS NULL,
	Modèle nvarchar(255) COLLATE French_CI_AS NULL,
	[Puissance  / Capacité] nvarchar(255) COLLATE French_CI_AS NULL
);


-- logiclim.dbo.C33 definition

-- Drop table

-- DROP TABLE logiclim.dbo.C33;

CREATE TABLE logiclim.dbo.C33 (
	numcli int NULL,
	cptsit int NULL,
	AGENCE nvarchar(255) COLLATE French_CI_AS NULL,
	ADRESSE nvarchar(255) COLLATE French_CI_AS NULL,
	CP float NULL,
	VILLE nvarchar(255) COLLATE French_CI_AS NULL,
	[N° installation] float NULL,
	FREON nvarchar(255) COLLATE French_CI_AS NULL,
	[Quantité fréon] nvarchar(255) COLLATE French_CI_AS NULL,
	[Désignation matériel] nvarchar(255) COLLATE French_CI_AS NULL,
	Marque nvarchar(255) COLLATE French_CI_AS NULL,
	[Type] nvarchar(255) COLLATE French_CI_AS NULL,
	Année nvarchar(255) COLLATE French_CI_AS NULL,
	Modèle nvarchar(255) COLLATE French_CI_AS NULL,
	[Puissance  / Capacité] nvarchar(255) COLLATE French_CI_AS NULL
);


-- logiclim.dbo.ChampRepertoireTechnique definition

-- Drop table

-- DROP TABLE logiclim.dbo.ChampRepertoireTechnique;

CREATE TABLE logiclim.dbo.ChampRepertoireTechnique (
	numcha int IDENTITY(1,1) NOT NULL,
	nomcha varchar(150) COLLATE French_CI_AS NOT NULL,
	nomintcha varchar(150) COLLATE French_CI_AS NOT NULL,
	CONSTRAINT PK_ChampRepertoireTechnique PRIMARY KEY (numcha)
);


-- logiclim.dbo.Client definition

-- Drop table

-- DROP TABLE logiclim.dbo.Client;

CREATE TABLE logiclim.dbo.Client (
	numcli int IDENTITY(1,1) NOT NULL,
	nomcli nvarchar(50) COLLATE French_CI_AS NULL,
	adrcli nvarchar(50) COLLATE French_CI_AS NULL,
	codposcli nvarchar(50) COLLATE French_CI_AS NULL,
	vilcli nvarchar(50) COLLATE French_CI_AS NULL,
	telcli nvarchar(50) COLLATE French_CI_AS NULL,
	faxcli nvarchar(50) COLLATE French_CI_AS NULL,
	concli nvarchar(50) COLLATE French_CI_AS NULL,
	melcli nvarchar(50) COLLATE French_CI_AS NULL,
	hormaxintcli real NULL,
	logcli image NULL,
	cheminpho varchar(255) COLLATE French_CI_AS NULL,
	cheminpla varchar(255) COLLATE French_CI_AS NULL,
	affcli bit DEFAULT 1 NULL,
	coutheuremainoeuvre real NULL,
	coutdeplacement real NULL,
	CONSTRAINT IX_Client UNIQUE (nomcli),
	CONSTRAINT PK_Client PRIMARY KEY (numcli)
);


-- logiclim.dbo.ClientCredential definition

-- Drop table

-- DROP TABLE logiclim.dbo.ClientCredential;

CREATE TABLE logiclim.dbo.ClientCredential (
	id int IDENTITY(1,1) NOT NULL,
	numcli int NOT NULL,
	[login] varchar(32) COLLATE French_CI_AS NOT NULL,
	password varchar(32) COLLATE French_CI_AS NOT NULL,
	CONSTRAINT PK_ClientCredential PRIMARY KEY (id)
);


-- logiclim.dbo.ClientRMA definition

-- Drop table

-- DROP TABLE logiclim.dbo.ClientRMA;

CREATE TABLE logiclim.dbo.ClientRMA (
	ID float NULL,
	Client nvarchar(255) COLLATE French_CI_AS NULL,
	[N° Client interne] float NULL,
	[N° Compteur Site] float NULL,
	[N° Site] float NULL,
	[Code Site] nvarchar(255) COLLATE French_CI_AS NULL,
	[Nom Site] nvarchar(255) COLLATE French_CI_AS NULL,
	Situation nvarchar(255) COLLATE French_CI_AS NULL,
	Adresse nvarchar(255) COLLATE French_CI_AS NULL,
	CP nvarchar(255) COLLATE French_CI_AS NULL,
	Ville nvarchar(255) COLLATE French_CI_AS NULL,
	Téléphone nvarchar(255) COLLATE French_CI_AS NULL,
	Fax nvarchar(255) COLLATE French_CI_AS NULL,
	Civilité nvarchar(255) COLLATE French_CI_AS NULL,
	[Nom Responsable] nvarchar(255) COLLATE French_CI_AS NULL,
	[Prénom Responsable] nvarchar(255) COLLATE French_CI_AS NULL,
	[Zone Géo] float NULL,
	[Surface Vente] float NULL,
	[Surface Totale] float NULL,
	[Nbre Entretien] float NULL,
	nbrdesenfsit nvarchar(255) COLLATE French_CI_AS NULL,
	[Date Dernière Visite Désenfumage] nvarchar(255) COLLATE French_CI_AS NULL,
	Commentaire nvarchar(255) COLLATE French_CI_AS NULL,
	[Tél Centre Commercial] nvarchar(255) COLLATE French_CI_AS NULL,
	[Date Création du Site] nvarchar(255) COLLATE French_CI_AS NULL,
	[Montant redevance] money NULL,
	[Indicateur Qualité] float NULL,
	[Indicateur Vetusté] float NULL,
	[Indicateur Puissance] float NULL,
	[Indicateur Accessibilité] float NULL,
	[Date Prise en charge] datetime NULL,
	hor_lun_ouv varchar(5) COLLATE French_CI_AS NULL,
	hor_lun_fer varchar(5) COLLATE French_CI_AS NULL,
	hor_mar_ouv varchar(5) COLLATE French_CI_AS NULL,
	hor_mar_fer varchar(5) COLLATE French_CI_AS NULL,
	hor_mer_ouv varchar(5) COLLATE French_CI_AS NULL,
	hor_mer_fer varchar(5) COLLATE French_CI_AS NULL,
	hor_jeu_ouv varchar(5) COLLATE French_CI_AS NULL,
	hor_jeu_fer varchar(5) COLLATE French_CI_AS NULL,
	hor_ven_ouv varchar(5) COLLATE French_CI_AS NULL,
	hor_ven_fer varchar(5) COLLATE French_CI_AS NULL,
	hor_sam_ouv varchar(5) COLLATE French_CI_AS NULL,
	hor_sam_fer varchar(5) COLLATE French_CI_AS NULL,
	hor_dim_ouv varchar(5) COLLATE French_CI_AS NULL,
	hor_dim_fer varchar(5) COLLATE French_CI_AS NULL,
	[Type de fluide] nvarchar(255) COLLATE French_CI_AS NULL,
	typfluidid int NULL,
	[T° Entrée] nvarchar(255) COLLATE French_CI_AS NULL,
	[T° Sortie] nvarchar(255) COLLATE French_CI_AS NULL,
	Champ50 nvarchar(255) COLLATE French_CI_AS NULL,
	[Code Intervenant] nvarchar(255) COLLATE French_CI_AS NULL,
	[Créée le] datetime NULL,
	[Date de mise à jour] datetime NULL,
	longitude float NULL,
	latitude float NULL,
	[date 1er maintenance ] datetime NULL,
	[DATE 2 EME MAINTENANCE ] datetime NULL,
	[lien vers fiche d'inter ] nvarchar(255) COLLATE French_CI_AS NULL,
	[date derniere visite desemfumage ] nvarchar(255) COLLATE French_CI_AS NULL,
	[lien vers fiche d'inter 1] nvarchar(255) COLLATE French_CI_AS NULL,
	INTERVENANT nvarchar(255) COLLATE French_CI_AS NULL,
	[ENTREPRISE REFERANTE] nvarchar(255) COLLATE French_CI_AS NULL,
	numintervenant int NULL
);


-- logiclim.dbo.ClientRMANew definition

-- Drop table

-- DROP TABLE logiclim.dbo.ClientRMANew;

CREATE TABLE logiclim.dbo.ClientRMANew (
	compteur int IDENTITY(1,1) NOT NULL,
	ID float NULL,
	Client nvarchar(255) COLLATE French_CI_AS NULL,
	[N° Client interne] float NULL,
	[N° Compteur Site] float NULL,
	[N° Site] nvarchar(255) COLLATE French_CI_AS NULL,
	Champ7 nvarchar(255) COLLATE French_CI_AS NULL,
	[Code Site] nvarchar(255) COLLATE French_CI_AS NULL,
	[Nom Site] nvarchar(255) COLLATE French_CI_AS NULL,
	Situation nvarchar(255) COLLATE French_CI_AS NULL,
	Champ9 nvarchar(255) COLLATE French_CI_AS NULL,
	Adresse nvarchar(255) COLLATE French_CI_AS NULL,
	CP nvarchar(255) COLLATE French_CI_AS NULL,
	Ville nvarchar(255) COLLATE French_CI_AS NULL,
	Téléphone nvarchar(255) COLLATE French_CI_AS NULL,
	Fax nvarchar(255) COLLATE French_CI_AS NULL,
	Civilité nvarchar(255) COLLATE French_CI_AS NULL,
	[Nom Responsable] nvarchar(255) COLLATE French_CI_AS NULL,
	[Prénom Responsable] nvarchar(255) COLLATE French_CI_AS NULL,
	[Zone Géo] float NULL,
	[Surface Vente] float NULL,
	[Surface Totale] float NULL,
	[Nbre Entretien] float NULL,
	nbrdesenfsit nvarchar(255) COLLATE French_CI_AS NULL,
	[Date Dernière Visite Désenfumage] nvarchar(255) COLLATE French_CI_AS NULL,
	Commentaire nvarchar(255) COLLATE French_CI_AS NULL,
	[Tél Centre Commercial] nvarchar(255) COLLATE French_CI_AS NULL,
	[Date Création du Site] nvarchar(255) COLLATE French_CI_AS NULL,
	[Montant redevance] money NULL,
	[Indicateur Qualité] float NULL,
	[Indicateur Vetusté] float NULL,
	[Indicateur Puissance] float NULL,
	[Indicateur Accessibilité] float NULL,
	[Date Prise en charge] datetime NULL,
	hor_lun_ouv nvarchar(255) COLLATE French_CI_AS NULL,
	hor_lun_fer nvarchar(255) COLLATE French_CI_AS NULL,
	hor_mar_ouv nvarchar(255) COLLATE French_CI_AS NULL,
	hor_mar_fer nvarchar(255) COLLATE French_CI_AS NULL,
	hor_mer_ouv nvarchar(255) COLLATE French_CI_AS NULL,
	hor_mer_fer nvarchar(255) COLLATE French_CI_AS NULL,
	hor_jeu_ouv nvarchar(255) COLLATE French_CI_AS NULL,
	hor_jeu_fer nvarchar(255) COLLATE French_CI_AS NULL,
	hor_ven_ouv nvarchar(255) COLLATE French_CI_AS NULL,
	hor_ven_fer nvarchar(255) COLLATE French_CI_AS NULL,
	hor_sam_ouv nvarchar(255) COLLATE French_CI_AS NULL,
	hor_sam_fer nvarchar(255) COLLATE French_CI_AS NULL,
	hor_dim_ouv nvarchar(255) COLLATE French_CI_AS NULL,
	hor_dim_fer nvarchar(255) COLLATE French_CI_AS NULL,
	[Type de fluide] nvarchar(255) COLLATE French_CI_AS NULL,
	[T° Entrée] nvarchar(255) COLLATE French_CI_AS NULL,
	[T° Sortie] nvarchar(255) COLLATE French_CI_AS NULL,
	Champ50 nvarchar(255) COLLATE French_CI_AS NULL,
	[Code Intervenant] nvarchar(255) COLLATE French_CI_AS NULL,
	[Créée le] datetime NULL,
	[Date de mise à jour] datetime NULL,
	longitude float NULL,
	latitude float NULL,
	[date 1er maintenance ] nvarchar(255) COLLATE French_CI_AS NULL,
	[lien vers fiche d'inter ] nvarchar(255) COLLATE French_CI_AS NULL,
	[date derniere visite desemfumage ] nvarchar(255) COLLATE French_CI_AS NULL,
	[lien vers fiche d'inter 1] nvarchar(255) COLLATE French_CI_AS NULL,
	INTERVENANT nvarchar(255) COLLATE French_CI_AS NULL,
	[ENTREPRISE REFERANTE] nvarchar(255) COLLATE French_CI_AS NULL,
	numintervenant int NULL,
	typfluidid int NULL,
	CONSTRAINT PK_ClientRMANew PRIMARY KEY (compteur)
);


-- logiclim.dbo.ClientUtilisateur definition

-- Drop table

-- DROP TABLE logiclim.dbo.ClientUtilisateur;

CREATE TABLE logiclim.dbo.ClientUtilisateur (
	numcli int NOT NULL,
	numuti int NOT NULL,
	CONSTRAINT PK_ClientUtilisateur PRIMARY KEY (numcli,numuti)
);


-- logiclim.dbo.Climserv definition

-- Drop table

-- DROP TABLE logiclim.dbo.Climserv;

CREATE TABLE logiclim.dbo.Climserv (
	id int IDENTITY(1,1) NOT NULL,
	NomPrenom varchar(50) COLLATE French_CI_AS NOT NULL,
	CONSTRAINT PK_Climserv PRIMARY KEY (id)
);


-- logiclim.dbo.Contact definition

-- Drop table

-- DROP TABLE logiclim.dbo.Contact;

CREATE TABLE logiclim.dbo.Contact (
	codcon nvarchar(50) COLLATE French_CI_AS NOT NULL,
	nomcon nvarchar(50) COLLATE French_CI_AS NULL,
	precon nvarchar(50) COLLATE French_CI_AS NULL,
	numcli int NULL,
	adrmelcon nvarchar(63) COLLATE French_CI_AS NULL,
	telcon nvarchar(50) COLLATE French_CI_AS NULL,
	faxcon nvarchar(50) COLLATE French_CI_AS NULL,
	mobcon nvarchar(50) COLLATE French_CI_AS NULL,
	obscon nvarchar(MAX) COLLATE French_CI_AS NULL,
	foncon nvarchar(50) COLLATE French_CI_AS NULL,
	civcon nvarchar(50) COLLATE French_CI_AS NULL,
	numdonneur int NULL,
	CONSTRAINT PK_Contact PRIMARY KEY (codcon)
);
 CREATE NONCLUSTERED INDEX IX_Contact ON logiclim.dbo.Contact (  numcli ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;


-- logiclim.dbo.ContratDeMaintenance definition

-- Drop table

-- DROP TABLE logiclim.dbo.ContratDeMaintenance;

CREATE TABLE logiclim.dbo.ContratDeMaintenance (
	NumeroDevis int IDENTITY(1,1) NOT NULL,
	NumeroDevisInterne nvarchar(50) COLLATE French_CI_AS NULL,
	StatutDevis tinyint DEFAULT 1 NOT NULL,
	NomFichierDevis varchar(1000) COLLATE French_CI_AS NULL,
	NomFichierDevisPartenaire varchar(1000) COLLATE French_CI_AS NULL,
	NumeroInterventionInterne int NULL,
	NumeroSite int NULL,
	CommentaireClientDevis varchar(2000) COLLATE French_CI_AS NULL,
	NumeroClient int NULL,
	MontantFournitureDevis float NULL,
	MainOeuvreDevis float NULL,
	NbreDeplacementDevis tinyint NULL,
	DateEnvoiDevis date NULL,
	EnvoyePar int NULL,
	NumeroPartenaire int NULL,
	NumeroDevisPartenaire nvarchar(50) COLLATE French_CI_AS NULL,
	MontantHTDevis float NULL,
	MontantHTDevisPartenaire float NULL,
	NumeroCommande nvarchar(50) COLLATE French_CI_AS NULL,
	DateDevis date NULL,
	TypePanneDevis nvarchar(100) COLLATE French_CI_AS NULL,
	QteMaterielDevis real NULL,
	coutheuremainoeuvre real NULL,
	coutdeplacement real NULL,
	NumeroDevisRemplacement nvarchar(50) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_ContratDeMaintenance PRIMARY KEY (NumeroDevis)
);


-- logiclim.dbo.Demande_Web definition

-- Drop table

-- DROP TABLE logiclim.dbo.Demande_Web;

CREATE TABLE logiclim.dbo.Demande_Web (
	Type_Demande int NOT NULL,
	NumUser int NOT NULL,
	Data1 int NULL,
	Data2 int NULL,
	Data3 nchar(10) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_Demande_Web PRIMARY KEY (NumUser)
);


-- logiclim.dbo.Devis definition

-- Drop table

-- DROP TABLE logiclim.dbo.Devis;

CREATE TABLE logiclim.dbo.Devis (
	NumeroDevis int IDENTITY(1,1) NOT NULL,
	NumeroDevisInterne nvarchar(50) COLLATE French_CI_AS NULL,
	StatutDevis tinyint DEFAULT 1 NOT NULL,
	NomFichierDevis varchar(1000) COLLATE French_CI_AS NULL,
	NomFichierDevisPartenaire varchar(1000) COLLATE French_CI_AS NULL,
	NumeroInterventionInterne int NULL,
	NumeroSite int NULL,
	CommentaireClientDevis varchar(2000) COLLATE French_CI_AS NULL,
	NumeroClient int NULL,
	MontantFournitureDevis float NULL,
	MainOeuvreDevis float NULL,
	NbreDeplacementDevis tinyint NULL,
	DateEnvoiDevis date NULL,
	EnvoyePar int NULL,
	NumeroPartenaire int NULL,
	NumeroDevisPartenaire nvarchar(50) COLLATE French_CI_AS NULL,
	MontantHTDevis float NULL,
	MontantHTDevisPartenaire float NULL,
	NumeroCommande nvarchar(50) COLLATE French_CI_AS NULL,
	DateDevis date NULL,
	TypePanneDevis nvarchar(100) COLLATE French_CI_AS NULL,
	QteMaterielDevis real NULL,
	coutheuremainoeuvre real NULL,
	coutdeplacement real NULL,
	NumeroDevisRemplacement nvarchar(50) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_Devis PRIMARY KEY (NumeroDevis)
);
 CREATE NONCLUSTERED INDEX missing_index_10_9 ON logiclim.dbo.Devis (  NumeroSite ASC  , NumeroClient ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_12_11 ON logiclim.dbo.Devis (  NumeroInterventionInterne ASC  , NumeroSite ASC  , NumeroClient ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_14_13 ON logiclim.dbo.Devis (  NumeroSite ASC  , StatutDevis ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_45_44 ON logiclim.dbo.Devis (  NumeroClient ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_52_51 ON logiclim.dbo.Devis (  StatutDevis ASC  )  
	 INCLUDE ( NumeroDevis , NumeroDevisInterne ) 
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_54_53 ON logiclim.dbo.Devis (  StatutDevis ASC  , NumeroSite ASC  , NumeroClient ASC  , TypePanneDevis ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_57_56 ON logiclim.dbo.Devis (  NumeroSite ASC  , NumeroClient ASC  , TypePanneDevis ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_6_5 ON logiclim.dbo.Devis (  NumeroInterventionInterne ASC  )  
	 INCLUDE ( NumeroDevis ) 
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;


-- logiclim.dbo.DevisTravaux definition

-- Drop table

-- DROP TABLE logiclim.dbo.DevisTravaux;

CREATE TABLE logiclim.dbo.DevisTravaux (
	NumeroDevis int IDENTITY(1,1) NOT NULL,
	NumeroDevisInterne nvarchar(50) COLLATE French_CI_AS NULL,
	StatutDevis tinyint DEFAULT 1 NOT NULL,
	NomFichierDevis varchar(1000) COLLATE French_CI_AS NULL,
	NomFichierDevisPartenaire varchar(1000) COLLATE French_CI_AS NULL,
	NumeroInterventionInterne int NULL,
	NumeroSite int NULL,
	CommentaireClientDevis varchar(2000) COLLATE French_CI_AS NULL,
	NumeroClient int NULL,
	MontantFournitureDevis float NULL,
	MainOeuvreDevis float NULL,
	NbreDeplacementDevis tinyint NULL,
	DateEnvoiDevis date NULL,
	EnvoyePar int NULL,
	NumeroPartenaire int NULL,
	NumeroDevisPartenaire nvarchar(50) COLLATE French_CI_AS NULL,
	MontantHTDevis float NULL,
	MontantHTDevisPartenaire float NULL,
	NumeroCommande nvarchar(50) COLLATE French_CI_AS NULL,
	DateDevis date NULL,
	TypePanneDevis nvarchar(100) COLLATE French_CI_AS NULL,
	QteMaterielDevis real NULL,
	coutheuremainoeuvre real NULL,
	coutdeplacement real NULL,
	NumeroDevisRemplacement nvarchar(50) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_DevisTravaux PRIMARY KEY (NumeroDevis)
);


-- logiclim.dbo.Donneur definition

-- Drop table

-- DROP TABLE logiclim.dbo.Donneur;

CREATE TABLE logiclim.dbo.Donneur (
	donneurid int IDENTITY(1,1) NOT NULL,
	nomdonneur nvarchar(100) COLLATE French_CI_AS NULL,
	adrdonneur nvarchar(50) COLLATE French_CI_AS NULL,
	codposdonneur nvarchar(50) COLLATE French_CI_AS NULL,
	vildonneur nvarchar(50) COLLATE French_CI_AS NULL,
	teldonneur nvarchar(50) COLLATE French_CI_AS NULL,
	faxdonneur nvarchar(50) COLLATE French_CI_AS NULL,
	condonneur nvarchar(50) COLLATE French_CI_AS NULL,
	meldonneur nvarchar(50) COLLATE French_CI_AS NULL,
	hormaxintdonneur real NULL,
	logdonneur image NULL,
	cheminpho varchar(255) COLLATE French_CI_AS NULL,
	cheminpla varchar(255) COLLATE French_CI_AS NULL,
	affdonneur bit DEFAULT 1 NULL,
	sairapdonneur bit DEFAULT 0 NULL,
	CONSTRAINT PK_Donneur PRIMARY KEY (donneurid)
);


-- logiclim.dbo.EvVehicules definition

-- Drop table

-- DROP TABLE logiclim.dbo.EvVehicules;

CREATE TABLE logiclim.dbo.EvVehicules (
	NumEV int IDENTITY(1,1) NOT NULL,
	DateEv date NOT NULL,
	Km int NOT NULL,
	Conducteur int NULL,
	Immat nchar(10) COLLATE French_CI_AS NOT NULL,
	TypeEv smallint NOT NULL,
	CONSTRAINT PK_EvVehicules PRIMARY KEY (NumEV)
);


-- logiclim.dbo.FicheIntervention definition

-- Drop table

-- DROP TABLE logiclim.dbo.FicheIntervention;

CREATE TABLE logiclim.dbo.FicheIntervention (
	numFicheInt int IDENTITY(1,1) NOT NULL,
	numIntInt int NULL,
	numBon int NULL,
	dateFicheInt datetime NULL,
	heureDebut datetime NULL,
	heureFin datetime NULL,
	tempsAller real NULL,
	tempsRetour real NULL,
	ficheInt1 char(10) COLLATE French_CI_AS NULL,
	ficheInt2 char(10) COLLATE French_CI_AS NULL,
	ficheInt3 char(10) COLLATE French_CI_AS NULL,
	ficheInt4 char(10) COLLATE French_CI_AS NULL,
	remarques ntext COLLATE French_CI_AS NULL,
	creele datetime DEFAULT getdate() NULL,
	majle datetime NULL,
	CONSTRAINT PK_FicheIntervention PRIMARY KEY (numFicheInt)
);


-- logiclim.dbo.FiltreClimAccessMobile definition

-- Drop table

-- DROP TABLE logiclim.dbo.FiltreClimAccessMobile;

CREATE TABLE logiclim.dbo.FiltreClimAccessMobile (
	DateDebut datetime NULL,
	DateFin datetime NULL,
	id int NOT NULL,
	CONSTRAINT PK_FiltreClimAccessMobile PRIMARY KEY (id)
);


-- logiclim.dbo.HeuresTech definition

-- Drop table

-- DROP TABLE logiclim.dbo.HeuresTech;

CREATE TABLE logiclim.dbo.HeuresTech (
	Numero int IDENTITY(1,1) NOT NULL,
	NumeroTech int NULL,
	TypeInterv int NULL,
	NumInterv int NULL,
	NomInterv nvarchar(1000) COLLATE French_CI_AS NULL,
	DateInterv date NULL,
	HeureDebut time(0) NULL,
	HeureFin time(0) NULL,
	InterdictionModif bit DEFAULT 0 NOT NULL,
	NumeroSite int NULL,
	HeureDebut_FMC time(0) NULL,
	HeureFin_FMC time(0) NULL,
	DateSaisie datetime NULL,
	NePasComptabiliser bit DEFAULT 0 NOT NULL,
	CONSTRAINT PK_HeuresTech PRIMARY KEY (Numero)
);


-- logiclim.dbo.HeuresTechAuto definition

-- Drop table

-- DROP TABLE logiclim.dbo.HeuresTechAuto;

CREATE TABLE logiclim.dbo.HeuresTechAuto (
	Numero int IDENTITY(1,1) NOT NULL,
	NumeroTech int NULL,
	TypeInterv int NULL,
	NumInterv int NULL,
	NomInterv nvarchar(1000) COLLATE French_CI_AS NULL,
	DateInterv date NULL,
	HeureDebut time(0) NULL,
	HeureFin time NULL,
	InterdictionModif bit DEFAULT 0 NOT NULL,
	NumeroSite int NULL,
	CONSTRAINT PK_HeuresTechAuto PRIMARY KEY (Numero)
);


-- logiclim.dbo.InterventionTechnicien definition

-- Drop table

-- DROP TABLE logiclim.dbo.InterventionTechnicien;

CREATE TABLE logiclim.dbo.InterventionTechnicien (
	numint int NULL,
	numuti int NOT NULL,
	numintuti int IDENTITY(1,1) NOT NULL,
	numintint int NULL,
	CONSTRAINT PK_InterventionTechnicien PRIMARY KEY (numintuti)
);


-- logiclim.dbo.Intervention_Status_Changed_history definition

-- Drop table

-- DROP TABLE logiclim.dbo.Intervention_Status_Changed_history;

CREATE TABLE logiclim.dbo.Intervention_Status_Changed_history (
	historyint int IDENTITY(1,1) NOT NULL,
	numintint int NOT NULL,
	CONSTRAINT PK_Intervention_Status_Changed_history PRIMARY KEY (historyint)
);


-- logiclim.dbo.JoursFeries definition

-- Drop table

-- DROP TABLE logiclim.dbo.JoursFeries;

CREATE TABLE logiclim.dbo.JoursFeries (
	numjou int IDENTITY(1,1) NOT NULL,
	datjoufer smalldatetime NULL,
	CONSTRAINT PK_JoursFeries PRIMARY KEY (numjou)
);


-- logiclim.dbo.ListeEVVehicule definition

-- Drop table

-- DROP TABLE logiclim.dbo.ListeEVVehicule;

CREATE TABLE logiclim.dbo.ListeEVVehicule (
	Numero int IDENTITY(1,1) NOT NULL,
	Evenement_Vehicule nchar(50) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_ListeEVVehicule PRIMARY KEY (Numero)
);


-- logiclim.dbo.ListeEtatVehicule definition

-- Drop table

-- DROP TABLE logiclim.dbo.ListeEtatVehicule;

CREATE TABLE logiclim.dbo.ListeEtatVehicule (
	Numero int IDENTITY(1,1) NOT NULL,
	EtatVehicule nchar(30) COLLATE French_CI_AS NOT NULL,
	CONSTRAINT PK_ListeEtatVehicule PRIMARY KEY (Numero)
);


-- logiclim.dbo.Liste_Type_Gaz definition

-- Drop table

-- DROP TABLE logiclim.dbo.Liste_Type_Gaz;

CREATE TABLE logiclim.dbo.Liste_Type_Gaz (
	id int IDENTITY(1,1) NOT NULL,
	Libelle nchar(20) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_Liste_Type_Gaz PRIMARY KEY (id)
);


-- logiclim.dbo.Marque definition

-- Drop table

-- DROP TABLE logiclim.dbo.Marque;

CREATE TABLE logiclim.dbo.Marque (
	nummar int IDENTITY(1,1) NOT NULL,
	nommar nvarchar(50) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_Marque PRIMARY KEY (nummar)
);


-- logiclim.dbo.ModeResolution definition

-- Drop table

-- DROP TABLE logiclim.dbo.ModeResolution;

CREATE TABLE logiclim.dbo.ModeResolution (
	nummodres int IDENTITY(1,1) NOT NULL,
	libmodres nvarchar(255) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_ModeResolution PRIMARY KEY (nummodres)
);


-- logiclim.dbo.ModeleRepertoireTechnique definition

-- Drop table

-- DROP TABLE logiclim.dbo.ModeleRepertoireTechnique;

CREATE TABLE logiclim.dbo.ModeleRepertoireTechnique (
	nummod int IDENTITY(1,1) NOT NULL,
	nommod varchar(100) COLLATE French_CI_AS NULL,
	datcremod datetime DEFAULT getdate() NULL,
	CONSTRAINT IX_ModeleRepertoireTechnique UNIQUE (nommod),
	CONSTRAINT PK_ModeleRepertoireTechnique PRIMARY KEY (nummod)
);


-- logiclim.dbo.Panne definition

-- Drop table

-- DROP TABLE logiclim.dbo.Panne;

CREATE TABLE logiclim.dbo.Panne (
	codpan int NOT NULL,
	libpan nvarchar(50) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_Panne PRIMARY KEY (codpan)
);


-- logiclim.dbo.PanneMaterielSite definition

-- Drop table

-- DROP TABLE logiclim.dbo.PanneMaterielSite;

CREATE TABLE logiclim.dbo.PanneMaterielSite (
	numintint int NULL,
	datedebut date NULL,
	datefin date NULL,
	numsitmarref int NULL,
	id int IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_PanneMaterielSite PRIMARY KEY (id)
);


-- logiclim.dbo.Photo definition

-- Drop table

-- DROP TABLE logiclim.dbo.Photo;

CREATE TABLE logiclim.dbo.Photo (
	numpho int IDENTITY(1,1) NOT NULL,
	nompho nvarchar(255) COLLATE French_CI_AS NULL,
	datcrepho smalldatetime NULL,
	despho ntext COLLATE French_CI_AS NULL,
	forpho nvarchar(3) COLLATE French_CI_AS NULL,
	numsitpho int NULL,
	CONSTRAINT PK_Photo PRIMARY KEY (numpho)
);


-- logiclim.dbo.[Plan] definition

-- Drop table

-- DROP TABLE logiclim.dbo.[Plan];

CREATE TABLE logiclim.dbo.[Plan] (
	numplan int IDENTITY(1,1) NOT NULL,
	nomplan nvarchar(50) COLLATE French_CI_AS NULL,
	datcreplan datetime NULL,
	desplan ntext COLLATE French_CI_AS NULL,
	forplan nvarchar(3) COLLATE French_CI_AS NULL,
	numsitplan int DEFAULT 0 NULL,
	CONSTRAINT aaaaaPlan_PK PRIMARY KEY (numplan)
);


-- logiclim.dbo.Plan1 definition

-- Drop table

-- DROP TABLE logiclim.dbo.Plan1;

CREATE TABLE logiclim.dbo.Plan1 (
	numplan int IDENTITY(1,1) NOT NULL,
	nomplan nvarchar(50) COLLATE French_CI_AS NULL,
	datcreplan datetime NULL,
	desplan ntext COLLATE French_CI_AS NULL,
	forplan nvarchar(3) COLLATE French_CI_AS NULL,
	numsitplan int DEFAULT 0 NULL,
	CONSTRAINT aaaaaPlan1_PK PRIMARY KEY (numplan)
);


-- logiclim.dbo.Planification definition

-- Drop table

-- DROP TABLE logiclim.dbo.Planification;

CREATE TABLE logiclim.dbo.Planification (
	numeroplanification int IDENTITY(1,1) NOT NULL,
	numcli int NULL,
	T1 date NULL,
	T2 date NULL,
	T3 date NULL,
	T4 date NULL,
	T5 date NULL,
	T6 date NULL,
	T7 date NULL,
	T8 date NULL,
	T9 date NULL,
	T10 date NULL,
	T11 date NULL,
	T12 date NULL,
	nombrevisite tinyint NULL,
	recurrent bit DEFAULT 0 NOT NULL,
	datefinrecurrence date NULL,
	CONSTRAINT PK_Planification PRIMARY KEY (numeroplanification)
);


-- logiclim.dbo.Plans definition

-- Drop table

-- DROP TABLE logiclim.dbo.Plans;

CREATE TABLE logiclim.dbo.Plans (
	numplan int IDENTITY(1,1) NOT NULL,
	nomplan nvarchar(50) COLLATE French_CI_AS NULL,
	datcreplan smalldatetime NULL,
	desplan ntext COLLATE French_CI_AS NULL,
	forplan nvarchar(3) COLLATE French_CI_AS NULL,
	numsitplan int NULL,
	CONSTRAINT PK_Plans PRIMARY KEY (numplan)
);


-- logiclim.dbo.Reference definition

-- Drop table

-- DROP TABLE logiclim.dbo.Reference;

CREATE TABLE logiclim.dbo.Reference (
	id int IDENTITY(1,1) NOT NULL,
	Reference nchar(50) COLLATE French_CI_AS NOT NULL,
	Repere nchar(50) COLLATE French_CI_AS NOT NULL,
	[Type] nchar(50) COLLATE French_CI_AS NOT NULL,
	Nommar nchar(50) COLLATE French_CI_AS NOT NULL,
	Fluide nchar(50) COLLATE French_CI_AS NOT NULL,
	TypeTel nchar(50) COLLATE French_CI_AS NOT NULL,
	Reversible nchar(50) COLLATE French_CI_AS NOT NULL,
	Resistance nchar(50) COLLATE French_CI_AS NOT NULL,
	PuissanceFrigo nchar(50) COLLATE French_CI_AS NOT NULL,
	PuissanceCalo nchar(50) COLLATE French_CI_AS NOT NULL,
	QteGaz nchar(50) COLLATE French_CI_AS NOT NULL,
	NbFiltres nchar(50) COLLATE French_CI_AS NULL,
	DimFiltres nchar(50) COLLATE French_CI_AS NULL,
	NbCourroies nchar(50) COLLATE French_CI_AS NULL,
	RefCourroies nchar(50) COLLATE French_CI_AS NULL,
	AppointRoof nchar(50) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_Reference PRIMARY KEY (id)
);


-- logiclim.dbo.Repere definition

-- Drop table

-- DROP TABLE logiclim.dbo.Repere;

CREATE TABLE logiclim.dbo.Repere (
	id int IDENTITY(1,1) NOT NULL,
	Repere nchar(50) COLLATE French_CI_AS NOT NULL,
	CtrlEtancheite bit DEFAULT 0 NOT NULL,
	CONSTRAINT PK_Repere PRIMARY KEY (id)
);


-- logiclim.dbo.Site definition

-- Drop table

-- DROP TABLE logiclim.dbo.Site;

CREATE TABLE logiclim.dbo.Site (
	cptsit int IDENTITY(1,1) NOT NULL,
	numsit int NULL,
	numcli int NOT NULL,
	codsit nvarchar(50) COLLATE French_CI_AS NULL,
	nomsit nvarchar(100) COLLATE French_CI_AS NULL,
	nomsocsit nvarchar(100) COLLATE French_CI_AS NULL,
	sitsit nvarchar(50) COLLATE French_CI_AS NULL,
	typsit nvarchar(50) COLLATE French_CI_AS NULL,
	adrsit nvarchar(100) COLLATE French_CI_AS NULL,
	codpossit nvarchar(10) COLLATE French_CI_AS NULL,
	vilsit nvarchar(50) COLLATE French_CI_AS NULL,
	telsit nvarchar(50) COLLATE French_CI_AS NULL,
	faxsit nvarchar(50) COLLATE French_CI_AS NULL,
	civres nvarchar(50) COLLATE French_CI_AS NULL,
	nomres nvarchar(50) COLLATE French_CI_AS NULL,
	preres nvarchar(50) COLLATE French_CI_AS NULL,
	numzonsit int NULL,
	surven real NULL,
	surtot real NULL,
	nbrentsit int NULL,
	nbrdesenfsit int NULL,
	datdervisdes smalldatetime NULL,
	comsit ntext COLLATE French_CI_AS NULL,
	telcencom nvarchar(50) COLLATE French_CI_AS NULL,
	datcresit nvarchar(50) COLLATE French_CI_AS NULL,
	demixasit bit DEFAULT 0 NOT NULL,
	mntredev real NULL,
	indclitec tinyint NULL,
	indvetust tinyint NULL,
	indpuissance tinyint NULL,
	indaccessib tinyint NULL,
	nbrplan smallint NULL,
	nbrpho smallint NULL,
	allumageclim bit DEFAULT 0 NOT NULL,
	domotique bit DEFAULT 0 NOT NULL,
	accessfiltre bit DEFAULT 0 NOT NULL,
	datprisencharge smalldatetime NULL,
	misajoursecurite bit DEFAULT 0 NOT NULL,
	aspirateur bit DEFAULT 0 NOT NULL,
	hor_lun_ouv varchar(5) COLLATE French_CI_AS DEFAULT '09:00' NULL,
	hor_lun_fer varchar(5) COLLATE French_CI_AS DEFAULT '19:00' NULL,
	hor_mar_ouv varchar(5) COLLATE French_CI_AS DEFAULT '09:00' NULL,
	hor_mar_fer varchar(5) COLLATE French_CI_AS DEFAULT '19:00' NULL,
	hor_mer_ouv varchar(5) COLLATE French_CI_AS DEFAULT '09:00' NULL,
	hor_mer_fer varchar(5) COLLATE French_CI_AS DEFAULT '19:00' NULL,
	hor_jeu_ouv varchar(5) COLLATE French_CI_AS DEFAULT '09:00' NULL,
	hor_jeu_fer varchar(5) COLLATE French_CI_AS DEFAULT '19:00' NULL,
	hor_ven_ouv varchar(5) COLLATE French_CI_AS DEFAULT '09:00' NULL,
	hor_ven_fer varchar(5) COLLATE French_CI_AS DEFAULT '19:00' NULL,
	hor_sam_ouv varchar(5) COLLATE French_CI_AS DEFAULT '09:00' NULL,
	hor_sam_fer varchar(5) COLLATE French_CI_AS DEFAULT '19:00' NULL,
	hor_dim_ouv varchar(5) COLLATE French_CI_AS DEFAULT '09:00' NULL,
	hor_dim_fer varchar(5) COLLATE French_CI_AS DEFAULT '19:00' NULL,
	typfluid int NULL,
	temp_entree nvarchar(50) COLLATE French_CI_AS NULL,
	temp_sortie nvarchar(50) COLLATE French_CI_AS NULL,
	numzone2 int NULL,
	numintervenant int NULL,
	creele datetime DEFAULT getdate() NULL,
	majle datetime NULL,
	longitude decimal(6,3) NULL,
	latitude decimal(6,3) NULL,
	donneurid int NULL,
	chemindoc nvarchar(500) COLLATE French_CI_AS NULL,
	datesignaturecontrat date NULL,
	numerocontratclient nvarchar(50) COLLATE French_CI_AS NULL,
	commentaire nvarchar(MAX) COLLATE French_CI_AS NULL,
	photoafaire bit DEFAULT 0 NOT NULL,
	photofaite bit DEFAULT 0 NOT NULL,
	auditafaire bit DEFAULT 0 NOT NULL,
	auditfait bit DEFAULT 0 NOT NULL,
	controleetancheiteafaire bit DEFAULT 0 NOT NULL,
	controleetancheitefait bit DEFAULT 0 NOT NULL,
	majregistresecuriteafaire bit DEFAULT 0 NOT NULL,
	majregistresecuritefait bit DEFAULT 0 NOT NULL,
	montantredevancetechnique float NULL,
	montantredevancefiltre float NULL,
	nombrevisitetechnique tinyint NULL,
	nombrevisitefiltre tinyint NULL,
	numerocontratdesenfumage nvarchar(50) COLLATE French_CI_AS NULL,
	nombrevisitedesenfumage tinyint NULL,
	datedesenfumage date NULL,
	montantredevancedesenfumage float NULL,
	datedernierevisiteentretien datetime NULL,
	precisiongeo varchar(50) COLLATE French_CI_AS NULL,
	datefermeture date NULL,
	motiffermeture varchar(MAX) COLLATE French_CI_AS NULL,
	controleetancheiteponctuel bit DEFAULT 0 NOT NULL,
	fermeture bit DEFAULT 0 NOT NULL,
	datemiseenservicesite date NULL,
	garantiepiecesmainoeuvre tinyint NULL,
	garantiepieces tinyint NULL,
	garantiecompresseur tinyint NULL,
	melsti varchar(63) COLLATE French_CI_AS NULL,
	Mess_Devis varchar(MAX) COLLATE French_CI_AS NULL,
	NumEsabora nchar(50) COLLATE French_CI_AS NULL,
	NumSousTraitClim int NULL,
	TarifSousTraitClim real NULL,
	NumContratChaudiere nchar(50) COLLATE French_CI_AS NULL,
	DateContratChaudiere smalldatetime NULL,
	NombreContratChaudiere int NULL,
	mntredevContratChaudiere real NULL,
	NumSousTraitChaudiere int NULL,
	TarifSousTraitChaudiere real NULL,
	NumSousTraitDesenfum int NULL,
	TarifSousTraitDesenfum real NULL,
	AvecPrixSite bit DEFAULT 0 NOT NULL,
	PrixDepl real NULL,
	PrixMo real NULL,
	RDV_Prendre bit DEFAULT 0 NOT NULL,
	InfosCompl varchar(MAX) COLLATE French_CI_AS NULL,
	Invest bit DEFAULT 0 NOT NULL,
	CONSTRAINT PK_Site PRIMARY KEY (cptsit)
);
 CREATE NONCLUSTERED INDEX IX_Site ON logiclim.dbo.Site (  numcli ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX IX_Site_1 ON logiclim.dbo.Site (  numzonsit ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_78_77 ON logiclim.dbo.Site (  numsit ASC  )  
	 INCLUDE ( cptsit ) 
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;

-- Extended properties

EXEC logiclim.sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de plans', @level0type=N'Schema', @level0name=N'dbo', @level1type=N'Table', @level1name=N'Site', @level2type=N'Column', @level2name=N'nbrplan';
EXEC logiclim.sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de photos', @level0type=N'Schema', @level0name=N'dbo', @level1type=N'Table', @level1name=N'Site', @level2type=N'Column', @level2name=N'nbrpho';


-- logiclim.dbo.SiteMAJRegistre definition

-- Drop table

-- DROP TABLE logiclim.dbo.SiteMAJRegistre;

CREATE TABLE logiclim.dbo.SiteMAJRegistre (
	[N°] int IDENTITY(1,1) NOT NULL,
	cptsit int NOT NULL,
	[Date] smalldatetime NULL,
	CONSTRAINT PK_SiteMAJRegistre PRIMARY KEY ([N°])
);


-- logiclim.dbo.SiteMarqueReference definition

-- Drop table

-- DROP TABLE logiclim.dbo.SiteMarqueReference;

CREATE TABLE logiclim.dbo.SiteMarqueReference (
	cptsit int NULL,
	nummar int NULL,
	nomref nvarchar(50) COLLATE French_CI_AS NULL,
	des nvarchar(255) COLLATE French_CI_AS NULL,
	fluide nvarchar(50) COLLATE French_CI_AS NULL,
	qte real NULL,
	datmisser smalldatetime NULL,
	datfinser smalldatetime NULL,
	numsitmarref int IDENTITY(1,1) NOT NULL,
	indvet bit DEFAULT 0 NOT NULL,
	indvetplu bit DEFAULT 0 NOT NULL,
	indpri bit DEFAULT 0 NOT NULL,
	[type] nvarchar(50) COLLATE French_CI_AS NULL,
	climtecouinon nchar(3) COLLATE French_CI_AS NULL,
	numerochantier nvarchar(12) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_SiteMarqueReference_1 PRIMARY KEY (numsitmarref)
);


-- logiclim.dbo.SiteMarqueReferenceDesenfumage definition

-- Drop table

-- DROP TABLE logiclim.dbo.SiteMarqueReferenceDesenfumage;

CREATE TABLE logiclim.dbo.SiteMarqueReferenceDesenfumage (
	cptsit int NULL,
	des nvarchar(255) COLLATE French_CI_AS NULL,
	qte real NULL,
	datmisser smalldatetime NULL,
	datfinser smalldatetime NULL,
	numsitmarrefdes int IDENTITY(1,1) NOT NULL,
	vetust bit DEFAULT 0 NOT NULL,
	CONSTRAINT PK_SiteMarqueReferenceDesenfumage PRIMARY KEY (numsitmarrefdes)
);


-- logiclim.dbo.SiteMateriel definition

-- Drop table

-- DROP TABLE logiclim.dbo.SiteMateriel;

CREATE TABLE logiclim.dbo.SiteMateriel (
	NumeroSiteMateriel int IDENTITY(1,1) NOT NULL,
	NumeroSite int NULL,
	RepereSurSite smallint NULL,
	Repere nchar(50) COLLATE French_CI_AS NULL,
	Emplacement nvarchar(50) COLLATE French_CI_AS NULL,
	Quantite tinyint NULL,
	Marque nvarchar(50) COLLATE French_CI_AS NULL,
	[Type] nvarchar(100) COLLATE French_CI_AS NULL,
	Reference nvarchar(50) COLLATE French_CI_AS NULL,
	NumeroSerie nvarchar(50) COLLATE French_CI_AS NULL,
	Reversible char(5) COLLATE French_CI_AS DEFAULT '0' NULL,
	ResistanceElectrique char(5) COLLATE French_CI_AS NULL,
	PuissanceFrigo real NULL,
	PuissanceCalo real NULL,
	FluideQuantite nvarchar(50) COLLATE French_CI_AS NULL,
	DateMiseEnService nvarchar(20) COLLATE French_CI_AS NULL,
	TypeTelecommande nchar(20) COLLATE French_CI_AS NULL,
	NbreTelecommande tinyint NULL,
	EmplacementTelecommande nvarchar(50) COLLATE French_CI_AS NULL,
	Disjoncteurs nvarchar(50) COLLATE French_CI_AS NULL,
	DisjoncteurPrincipal nvarchar(50) COLLATE French_CI_AS NULL,
	DisjoncteurArmoirePrincipale nvarchar(50) COLLATE French_CI_AS NULL,
	DisjoncteurCoffretIndependant nvarchar(50) COLLATE French_CI_AS NULL,
	AccessibiliteGroupe nvarchar(50) COLLATE French_CI_AS NULL,
	AccessibiliteCassettes nvarchar(50) COLLATE French_CI_AS NULL,
	SupportGroupes nvarchar(60) COLLATE French_CI_AS NULL,
	EtatSupports tinyint NULL,
	NbreFiltreRoofTop tinyint NULL,
	ReferenceFiltreRoofTop nvarchar(30) COLLATE French_CI_AS NULL,
	NbreCourroiesRoofTop tinyint NULL,
	ReferenceCourroiesRoofTop nvarchar(50) COLLATE French_CI_AS NULL,
	AppointChauffageSurRoof nchar(30) COLLATE French_CI_AS NULL,
	NbreAerotherme nvarchar(10) COLLATE French_CI_AS NULL,
	AerothermeGazElec nchar(10) COLLATE French_CI_AS NULL,
	RideauAir bit DEFAULT 0 NOT NULL,
	NbreRideauType nvarchar(50) COLLATE French_CI_AS NULL,
	PuissanceRideau nchar(10) COLLATE French_CI_AS NULL,
	TypeDisjoncteurRideau nchar(40) COLLATE French_CI_AS NULL,
	SasEntree bit DEFAULT 0 NOT NULL,
	ClimLocauxSociauxEmplacement nvarchar(50) COLLATE French_CI_AS NULL,
	ClimLocauxSociauxEmplacementGroupeExterieur nvarchar(50) COLLATE French_CI_AS NULL,
	ClimLocauxSociauxMarque nvarchar(50) COLLATE French_CI_AS NULL,
	ClimLocauxSociauxType nvarchar(50) COLLATE French_CI_AS NULL,
	ClimLocauxSociauxReference nvarchar(50) COLLATE French_CI_AS NULL,
	ClimLocauxSociauxNumeroSerie nvarchar(50) COLLATE French_CI_AS NULL,
	ClimLocauxSociauxDateMiseService nvarchar(20) COLLATE French_CI_AS NULL,
	ClimLocauxSociauxReversible bit DEFAULT 0 NOT NULL,
	ClimLocauxSociauxFluideQuantite nvarchar(20) COLLATE French_CI_AS NULL,
	Radiateurs bit DEFAULT 0 NOT NULL,
	NbreRadiateurs real NULL,
	LocalisationRadiateurs nvarchar(50) COLLATE French_CI_AS NULL,
	DisjoncteurRadiateursTypeIntensite nvarchar(50) COLLATE French_CI_AS NULL,
	VMC bit DEFAULT 0 NOT NULL,
	LocalisationVMC nvarchar(50) COLLATE French_CI_AS NULL,
	Photos bit DEFAULT 0 NOT NULL,
	RapportsMaintenance nvarchar(MAX) COLLATE French_CI_AS NULL,
	DevisEnCours nvarchar(50) COLLATE French_CI_AS NULL,
	DevisValide nvarchar(50) COLLATE French_CI_AS NULL,
	ControleEtancheite nvarchar(50) COLLATE French_CI_AS NULL,
	Observations nvarchar(MAX) COLLATE French_CI_AS NULL,
	DateCE date NULL,
	CE_Edite bit DEFAULT 0 NOT NULL,
	NumeroInter int NULL,
	DateAchat date NULL,
	CONSTRAINT PK_SiteMateriel PRIMARY KEY (NumeroSiteMateriel)
);


-- logiclim.dbo.SiteNombreEntretien definition

-- Drop table

-- DROP TABLE logiclim.dbo.SiteNombreEntretien;

CREATE TABLE logiclim.dbo.SiteNombreEntretien (
	cptsit int NULL,
	nbrentsit int NULL,
	datfin smalldatetime NULL,
	[N°] int NOT NULL
);


-- logiclim.dbo.Societe definition

-- Drop table

-- DROP TABLE logiclim.dbo.Societe;

CREATE TABLE logiclim.dbo.Societe (
	numsoc int IDENTITY(1,1) NOT NULL,
	nomsoc nvarchar(50) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_Societe PRIMARY KEY (numsoc)
);


-- logiclim.dbo.SousType definition

-- Drop table

-- DROP TABLE logiclim.dbo.SousType;

CREATE TABLE logiclim.dbo.SousType (
	id int IDENTITY(1,1) NOT NULL,
	SousType nchar(50) COLLATE French_CI_AS NOT NULL,
	CONSTRAINT PK_SousType PRIMARY KEY (id)
);


-- logiclim.dbo.StatusInterv definition

-- Drop table

-- DROP TABLE logiclim.dbo.StatusInterv;

CREATE TABLE logiclim.dbo.StatusInterv (
	IndexLigne int IDENTITY(1,1) NOT NULL,
	StatutInter nchar(50) COLLATE French_CI_AS NOT NULL,
	OrdreAffichage int DEFAULT 0 NOT NULL,
	CONSTRAINT PK_StatusInterv PRIMARY KEY (IndexLigne)
);


-- logiclim.dbo.StatutFacture definition

-- Drop table

-- DROP TABLE logiclim.dbo.StatutFacture;

CREATE TABLE logiclim.dbo.StatutFacture (
	IndexLigne int IDENTITY(1,1) NOT NULL,
	Statut nchar(50) COLLATE French_CI_AS NOT NULL,
	OrdreAffichage int DEFAULT 0 NULL,
	QueKadi bit DEFAULT 0 NOT NULL,
	CONSTRAINT PK_StatutFacture PRIMARY KEY (IndexLigne)
);


-- logiclim.dbo.TopTen definition

-- Drop table

-- DROP TABLE logiclim.dbo.TopTen;

CREATE TABLE logiclim.dbo.TopTen (
	numtop int IDENTITY(1,1) NOT NULL,
	nomsittop nvarchar(50) COLLATE French_CI_AS NULL,
	indvettop int DEFAULT 0 NULL,
	Nbintphy int DEFAULT 0 NULL,
	nbintdef int DEFAULT 0 NULL,
	numsittop int DEFAULT 0 NULL,
	typsittop nvarchar(50) COLLATE French_CI_AS NULL,
	logclitop image NULL,
	CONSTRAINT aaaaaTopTen_PK PRIMARY KEY (numtop)
);


-- logiclim.dbo.TopTen1 definition

-- Drop table

-- DROP TABLE logiclim.dbo.TopTen1;

CREATE TABLE logiclim.dbo.TopTen1 (
	numtop int IDENTITY(1,1) NOT NULL,
	nomsittop nvarchar(50) COLLATE French_CI_AS NULL,
	indvettop int DEFAULT 0 NULL,
	Nbintphy int DEFAULT 0 NULL,
	nbintdef int DEFAULT 0 NULL,
	numsittop int DEFAULT 0 NULL,
	typsittop nvarchar(50) COLLATE French_CI_AS NULL,
	logclitop image NULL,
	CONSTRAINT aaaaaTopTen1_PK PRIMARY KEY (numtop)
);


-- logiclim.dbo.TypeAudit definition

-- Drop table

-- DROP TABLE logiclim.dbo.TypeAudit;

CREATE TABLE logiclim.dbo.TypeAudit (
	id int IDENTITY(1,1) NOT NULL,
	[Type] nchar(50) COLLATE French_CI_AS NOT NULL,
	CONSTRAINT PK_TypeAudit PRIMARY KEY (id)
);


-- logiclim.dbo.TypeFluide definition

-- Drop table

-- DROP TABLE logiclim.dbo.TypeFluide;

CREATE TABLE logiclim.dbo.TypeFluide (
	id int IDENTITY(1,1) NOT NULL,
	libelle varchar(50) COLLATE French_CI_AS NOT NULL,
	GWP int DEFAULT 0 NOT NULL,
	[Type] int DEFAULT 0 NOT NULL,
	CONSTRAINT PK_typefluide PRIMARY KEY (id)
);


-- logiclim.dbo.TypeInterv definition

-- Drop table

-- DROP TABLE logiclim.dbo.TypeInterv;

CREATE TABLE logiclim.dbo.TypeInterv (
	IndexLigne int IDENTITY(1,1) NOT NULL,
	TypeInter nchar(50) COLLATE French_CI_AS NOT NULL,
	OrdreAffichage int NOT NULL,
	IndexLigneSTRING nchar(50) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_TypeInterv PRIMARY KEY (IndexLigne)
);


-- logiclim.dbo.TypeTel definition

-- Drop table

-- DROP TABLE logiclim.dbo.TypeTel;

CREATE TABLE logiclim.dbo.TypeTel (
	id int IDENTITY(1,1) NOT NULL,
	TypeTelecommande nchar(50) COLLATE French_CI_AS NOT NULL,
	CONSTRAINT PK_TypeTel PRIMARY KEY (id)
);


-- logiclim.dbo.Utilisateur definition

-- Drop table

-- DROP TABLE logiclim.dbo.Utilisateur;

CREATE TABLE logiclim.dbo.Utilisateur (
	numuti int IDENTITY(1,1) NOT NULL,
	nomuti nvarchar(50) COLLATE French_CI_AS NULL,
	preuti nvarchar(50) COLLATE French_CI_AS NULL,
	loguti nvarchar(50) COLLATE French_CI_AS NULL,
	mdputi nvarchar(50) COLLATE French_CI_AS NULL,
	nomsocuti nvarchar(50) COLLATE French_CI_AS NULL,
	typuti int NULL,
	codintuti nvarchar(50) COLLATE French_CI_AS NULL,
	nummod int NULL,
	numsoc int NULL,
	Mail nchar(100) COLLATE French_CI_AS NULL,
	KmARenseigner bit DEFAULT 0 NOT NULL,
	Immat nchar(10) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_Utilisateur PRIMARY KEY (numuti)
);


-- logiclim.dbo.Vehicules definition

-- Drop table

-- DROP TABLE logiclim.dbo.Vehicules;

CREATE TABLE logiclim.dbo.Vehicules (
	EtatVehicule smallint DEFAULT 0 NOT NULL,
	Dernier_KM int NULL,
	Immatriculation nchar(10) COLLATE French_CI_AS NULL,
	DateMiseCirculation date NULL,
	KM_a_l_achat int NULL,
	Km_Inter_Revision int NULL,
	Temps_Mois_Inter_Revision smallint NULL,
	Champ_Libre nvarchar(MAX) COLLATE French_CI_AS NULL,
	Garantie bit DEFAULT 0 NOT NULL,
	Nb_KM_Garantie int NULL,
	Temps_Mois_Garantie int NULL,
	Leasing bit DEFAULT 0 NOT NULL,
	Nb_Km_Leasing int NULL,
	Temps_Mois_Leasing smallint NULL,
	Date_Fin_Leasing date NULL,
	Conducteur int NULL,
	NumTelepeage nchar(20) COLLATE French_CI_AS NULL,
	CodeCarteEssence nchar(15) COLLATE French_CI_AS NULL,
	NumCarteEssence nchar(15) COLLATE French_CI_AS NULL,
	Marque nchar(20) COLLATE French_CI_AS NULL,
	NumVehicule int IDENTITY(1,1) NOT NULL,
	Modele nchar(30) COLLATE French_CI_AS NULL,
	Societe int NULL,
	CritAir bit DEFAULT 0 NOT NULL,
	CONSTRAINT PK_Vehicules PRIMARY KEY (NumVehicule)
);


-- logiclim.dbo.VisitesMaint definition

-- Drop table

-- DROP TABLE logiclim.dbo.VisitesMaint;

CREATE TABLE logiclim.dbo.VisitesMaint (
	Nombre_Visites int NOT NULL,
	Ecart_Permis_Jour int NOT NULL,
	IndexLigne int IDENTITY(1,1) NOT NULL,
	Commentaire nchar(100) COLLATE French_CI_AS NULL,
	CONSTRAINT PK_VisitesMaint PRIMARY KEY (IndexLigne)
);


-- logiclim.dbo.ZoneGeographique definition

-- Drop table

-- DROP TABLE logiclim.dbo.ZoneGeographique;

CREATE TABLE logiclim.dbo.ZoneGeographique (
	numzon int IDENTITY(1,1) NOT NULL,
	nomzon nvarchar(50) COLLATE French_CI_AS NULL,
	CONSTRAINT IX_ZoneGeographique UNIQUE (nomzon),
	CONSTRAINT PK_ZoneGeographique PRIMARY KEY (numzon)
);


-- logiclim.dbo.ZoneSociete definition

-- Drop table

-- DROP TABLE logiclim.dbo.ZoneSociete;

CREATE TABLE logiclim.dbo.ZoneSociete (
	numzon int NOT NULL,
	numsoc int NOT NULL,
	id int IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_ZoneSociete PRIMARY KEY (id)
);


-- logiclim.dbo.annuaire definition

-- Drop table

-- DROP TABLE logiclim.dbo.annuaire;

CREATE TABLE logiclim.dbo.annuaire (
	AC nvarchar(255) COLLATE French_CI_AS NULL,
	[N°] float NULL,
	Magasin nvarchar(255) COLLATE French_CI_AS NULL,
	[H/F] nvarchar(255) COLLATE French_CI_AS NULL,
	Adresse nvarchar(255) COLLATE French_CI_AS NULL,
	code_postal float NULL,
	Ville nvarchar(255) COLLATE French_CI_AS NULL,
	F8 nvarchar(255) COLLATE French_CI_AS NULL,
	Directrice nvarchar(255) COLLATE French_CI_AS NULL,
	Téléphone nvarchar(255) COLLATE French_CI_AS NULL,
	[Abr# Tél] float NULL,
	Fax nvarchar(255) COLLATE French_CI_AS NULL,
	[Abr# Fax] float NULL
);


-- logiclim.dbo.dtproperties definition

-- Drop table

-- DROP TABLE logiclim.dbo.dtproperties;

CREATE TABLE logiclim.dbo.dtproperties (
	id int IDENTITY(1,1) NOT NULL,
	objectid int NULL,
	property varchar(64) COLLATE French_CI_AS NOT NULL,
	value varchar(255) COLLATE French_CI_AS NULL,
	uvalue nvarchar(255) COLLATE French_CI_AS NULL,
	lvalue image NULL,
	version int DEFAULT 0 NOT NULL,
	CONSTRAINT pk_dtproperties PRIMARY KEY (id,property)
);


-- logiclim.dbo.parametre definition

-- Drop table

-- DROP TABLE logiclim.dbo.parametre;

CREATE TABLE logiclim.dbo.parametre (
	numcli int NULL,
	datdeb datetime NULL,
	datfin datetime NULL,
	datfinpla datetime NULL
);


-- logiclim.dbo.parametre1 definition

-- Drop table

-- DROP TABLE logiclim.dbo.parametre1;

CREATE TABLE logiclim.dbo.parametre1 (
	numcli int NULL,
	datdeb datetime NULL,
	datfin datetime NULL,
	datfinpla datetime NULL
);


-- logiclim.dbo.planning definition

-- Drop table

-- DROP TABLE logiclim.dbo.planning;

CREATE TABLE logiclim.dbo.planning (
	numsit int NOT NULL,
	[Semaine 1] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 2] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 3] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 4] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 5] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 6] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 7] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 8] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 9] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 10] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 11] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 12] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 13] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 14] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 15] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 16] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 17] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 18] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 19] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 20] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 21] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 22] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 23] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 24] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 25] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 26] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 27] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 28] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 29] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 30] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 31] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 32] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 33] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 34] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 35] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 36] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 37] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 38] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 39] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 40] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 41] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 42] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 43] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 44] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 45] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 46] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 47] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 48] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 49] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 50] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 51] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 52] nvarchar(50) COLLATE French_CI_AS NULL,
	CONSTRAINT aaaaaplanning_PK PRIMARY KEY (numsit)
);


-- logiclim.dbo.planning1 definition

-- Drop table

-- DROP TABLE logiclim.dbo.planning1;

CREATE TABLE logiclim.dbo.planning1 (
	numsit int NOT NULL,
	[Semaine 1] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 2] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 3] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 4] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 5] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 6] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 7] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 8] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 9] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 10] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 11] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 12] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 13] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 14] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 15] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 16] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 17] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 18] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 19] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 20] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 21] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 22] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 23] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 24] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 25] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 26] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 27] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 28] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 29] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 30] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 31] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 32] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 33] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 34] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 35] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 36] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 37] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 38] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 39] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 40] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 41] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 42] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 43] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 44] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 45] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 46] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 47] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 48] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 49] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 50] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 51] nvarchar(50) COLLATE French_CI_AS NULL,
	[Semaine 52] nvarchar(50) COLLATE French_CI_AS NULL,
	CONSTRAINT aaaaaplanning1_PK PRIMARY KEY (numsit)
);


-- logiclim.dbo.HistoCnx definition

-- Drop table

-- DROP TABLE logiclim.dbo.HistoCnx;

CREATE TABLE logiclim.dbo.HistoCnx (
	HistoCnxId int IDENTITY(1,1) NOT NULL,
	numuti int NOT NULL,
	datheucnx datetime NOT NULL,
	CONSTRAINT PK_HistoCnx PRIMARY KEY (HistoCnxId),
	CONSTRAINT FK_HistoCnx_Utilisateur FOREIGN KEY (numuti) REFERENCES logiclim.dbo.Utilisateur(numuti)
);


-- logiclim.dbo.Intervenant definition

-- Drop table

-- DROP TABLE logiclim.dbo.Intervenant;

CREATE TABLE logiclim.dbo.Intervenant (
	codint nvarchar(10) COLLATE French_CI_AS NOT NULL,
	nomint nvarchar(50) COLLATE French_CI_AS NULL,
	numzonint int NULL,
	adrint nvarchar(50) COLLATE French_CI_AS NULL,
	codposint nvarchar(50) COLLATE French_CI_AS NULL,
	vilint nvarchar(50) COLLATE French_CI_AS NULL,
	telint nvarchar(50) COLLATE French_CI_AS NULL,
	faxint nvarchar(50) COLLATE French_CI_AS NULL,
	numintervenant int IDENTITY(1,1) NOT NULL,
	adrmelint nvarchar(63) COLLATE French_CI_AS NULL,
	NomDirigeant_Interv nvarchar(50) COLLATE French_CI_AS NULL,
	TelDirigeant_Interv nvarchar(50) COLLATE French_CI_AS NULL,
	Mail_Dirigeant_Interv nvarchar(50) COLLATE French_CI_AS NULL,
	NomInterlocuteur_Interv nvarchar(50) COLLATE French_CI_AS NULL,
	TelInterlocuteur_Interv nvarchar(50) COLLATE French_CI_AS NULL,
	Info_Interv nvarchar(512) COLLATE French_CI_AS NULL,
	Histo_FMC_Interv nvarchar(512) COLLATE French_CI_AS NULL,
	numzonint_2_Interv int NULL,
	numzonint_3_Interv int NULL,
	numzonint_4_Interv int NULL,
	VillesInterventions_Interv nvarchar(512) COLLATE French_CI_AS NULL,
	Activite_1 int NULL,
	Activite_2 int NULL,
	Activite_3 int NULL,
	Activite_4 int NULL,
	Activite_5 int NULL,
	Activite_6 int NULL,
	MO_Activite_1 real NULL,
	MO_Activite_2 real NULL,
	MO_Activite_3 real NULL,
	MO_Activite_4 real NULL,
	MO_Activite_5 real NULL,
	MO_Activite_6 real NULL,
	Depl_Activite_1 real NULL,
	Depl_Activite_2 real NULL,
	Depl_Activite_3 real NULL,
	Depl_Activite_4 real NULL,
	Depl_Activite_5 real NULL,
	Depl_Activite_6 real NULL,
	Latitude_Interv decimal(6,3) NULL,
	Longitude_Interv decimal(6,3) NULL,
	Rooftop_Interv nvarchar(50) COLLATE French_CI_AS NULL,
	PrecisionGeo_Interv nvarchar(50) COLLATE French_CI_AS NULL,
	Provenance_Interv nvarchar(50) COLLATE French_CI_AS NULL,
	ChargeAffaireFMC_Interv int NULL,
	CreePar_Interv int NULL,
	IndMaint_Interv tinyint NULL,
	Ind_Depann_Interv tinyint NULL,
	Ind_Travaux_Interv tinyint NULL,
	Ind_React_Interv tinyint NULL,
	DossierOrdi_Interv nvarchar(512) COLLATE French_CI_AS NULL,
	TexteNeplusInterv nvarchar(256) COLLATE French_CI_AS NULL,
	EstTech bit DEFAULT 0 NOT NULL,
	Date_Activite_1 smalldatetime NULL,
	Date_Activite_2 smalldatetime NULL,
	Date_Activite_3 smalldatetime NULL,
	Date_Activite_4 smalldatetime NULL,
	Date_Activite_5 smalldatetime NULL,
	Date_Activite_6 smalldatetime NULL,
	NePlusIntervenir bit DEFAULT 0 NOT NULL,
	Status_Prospect bit DEFAULT 0 NOT NULL,
	Status_ST_FMC bit DEFAULT 0 NOT NULL,
	Status_ST_FMC_Ponctuel bit DEFAULT 0 NOT NULL,
	Status_Act_Poss_Maint bit DEFAULT 0 NOT NULL,
	Status_Act_Poss_Depan bit DEFAULT 0 NOT NULL,
	Status_Act_Poss_Travaux bit DEFAULT 0 NOT NULL,
	Status_Act_Donn_Maint bit DEFAULT 0 NOT NULL,
	Status_Act_Donn_Depan bit DEFAULT 0 NOT NULL,
	Status_Act_Donn_Travaux bit DEFAULT 0 NOT NULL,
	Zone_Nationale bit DEFAULT 0 NOT NULL,
	MailFacturation nvarchar(50) COLLATE French_CI_AS NULL,
	SiteInternet nvarchar(128) COLLATE French_CI_AS NULL,
	ExistePlus bit DEFAULT 0 NOT NULL,
	AutoLiquidation bit DEFAULT 0 NOT NULL,
	CONSTRAINT PK_Intervenant_1 PRIMARY KEY (numintervenant),
	CONSTRAINT FK_Intervenant_ZoneGeographique FOREIGN KEY (numzonint) REFERENCES logiclim.dbo.ZoneGeographique(numzon)
);
 CREATE UNIQUE NONCLUSTERED INDEX IX_Codint ON logiclim.dbo.Intervenant (  codint ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX IX_Intervenant ON logiclim.dbo.Intervenant (  numzonint ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;


-- logiclim.dbo.Intervention definition

-- Drop table

-- DROP TABLE logiclim.dbo.Intervention;

CREATE TABLE logiclim.dbo.Intervention (
	numintint int IDENTITY(1,1) NOT NULL,
	numint int NULL,
	cptsit int NULL,
	codint nvarchar(10) COLLATE French_CI_AS NULL,
	typint nvarchar(50) COLLATE French_CI_AS DEFAULT '1' NULL,
	datintpre datetime NULL,
	heuintpre datetime NULL,
	datint datetime NULL,
	tpsallint datetime NULL,
	tpsretint datetime NULL,
	heuarrint datetime NULL,
	heudepint datetime NULL,
	codpan int NULL,
	comint ntext COLLATE French_CI_AS NULL,
	dirint ntext COLLATE French_CI_AS NULL,
	intfac bit DEFAULT 0 NOT NULL,
	intfactok bit DEFAULT 0 NOT NULL,
	intafact bit DEFAULT 0 NULL,
	codcon nvarchar(50) COLLATE French_CI_AS NULL,
	staint int NULL,
	refint nvarchar(50) COLLATE French_CI_AS NULL,
	refcliint nvarchar(50) COLLATE French_CI_AS NULL,
	nbrappint int NULL,
	mntfac float NULL,
	datheuapp datetime NULL,
	datheulim datetime NULL,
	pannoncli bit DEFAULT 0 NOT NULL,
	nbrpagfax int NULL,
	nummodres int NULL,
	numdev nvarchar(50) COLLATE French_CI_AS NULL,
	objint nvarchar(MAX) COLLATE French_CI_AS NULL,
	traitepar int NULL,
	majregsec bit DEFAULT 0 NOT NULL,
	sigsit varchar(MAX) COLLATE French_CI_AS NULL,
	sigtec varchar(MAX) COLLATE French_CI_AS NULL,
	sigcli varchar(MAX) COLLATE French_CI_AS NULL,
	creele datetime DEFAULT getdate() NULL,
	majle datetime NULL,
	nbrtecint int NULL,
	numdevacc nvarchar(50) COLLATE French_CI_AS NULL,
	saisiepar int NULL,
	imprimeepar int NULL,
	classeepar int NULL,
	prediagpar int NULL,
	envoisoustraitantpar int NULL,
	numerodemandesoustraitant nvarchar(50) COLLATE French_CI_AS NULL,
	retourficheinterventionpar int NULL,
	devisepar int NULL,
	duplicatacreepar int NULL,
	duplicatafait bit DEFAULT 0 NOT NULL,
	prediagres bit DEFAULT 0 NOT NULL,
	devisafaire bit DEFAULT 0 NOT NULL,
	numpartenaire int NULL,
	numdevpartenaire nvarchar(50) COLLATE French_CI_AS NULL,
	mnthtdevpartenaire float NULL,
	stadev int NULL,
	mnthtdevis float NULL,
	retourficheoriginal bit DEFAULT 0 NOT NULL,
	retourfichecopie bit DEFAULT 0 NOT NULL,
	retourfichecopieordi bit DEFAULT 0 NOT NULL,
	numerocommande nvarchar(300) COLLATE French_CI_AS NULL,
	cheficdemint nvarchar(500) COLLATE French_CI_AS NULL,
	visitegratuite bit DEFAULT 0 NOT NULL,
	datesignaturecontrat date NULL,
	numerocontratclient varchar(50) COLLATE French_CI_AS NULL,
	devisfait bit DEFAULT 0 NOT NULL,
	cheficdemcli nvarchar(500) COLLATE French_CI_AS NULL,
	comdevis nvarchar(MAX) COLLATE French_CI_AS NULL,
	devisanepasfaire bit DEFAULT 0 NOT NULL,
	controleetancheite bit DEFAULT 0 NOT NULL,
	natureintervention tinyint NULL,
	photofaite bit DEFAULT 0 NOT NULL,
	auditfait bit DEFAULT 0 NOT NULL,
	commajregsec nvarchar(MAX) COLLATE French_CI_AS NULL,
	sigtec2 varchar(MAX) COLLATE French_CI_AS NULL,
	sigcli2 varchar(MAX) COLLATE French_CI_AS NULL,
	sigsit2 varchar(MAX) COLLATE French_CI_AS NULL,
	sigtecimg nvarchar(MAX) COLLATE French_CI_AS NULL,
	sigcliimg nvarchar(MAX) COLLATE French_CI_AS NULL,
	sigsitimg nvarchar(MAX) COLLATE French_CI_AS NULL,
	controleetancheiteponctuel bit DEFAULT 0 NOT NULL,
	sigtecjson nvarchar(MAX) COLLATE French_CI_AS NULL,
	sigclijson nvarchar(MAX) COLLATE French_CI_AS NULL,
	sigsitbase64 nvarchar(MAX) COLLATE French_CI_AS NULL,
	comintposint nvarchar(MAX) COLLATE French_CI_AS NULL,
	numutipre int NULL,
	comtec nvarchar(MAX) COLLATE French_CI_AS NULL,
	heuvis bit DEFAULT 0 NOT NULL,
	mntfmc float NULL,
	mntst float NULL,
	comdevisinterne nvarchar(MAX) COLLATE French_CI_AS NULL,
	datefintech datetime NULL,
	dateenvoimail datetime NULL,
	rappel24h bit DEFAULT 0 NOT NULL,
	rappel48h bit DEFAULT 0 NOT NULL,
	rappel72h bit DEFAULT 0 NOT NULL,
	rappelsemaine bit DEFAULT 0 NOT NULL,
	CheminDossEtanch nvarchar(500) COLLATE French_CI_AS NULL,
	RV timestamp NOT NULL,
	CONSTRAINT PK_Intervention PRIMARY KEY (numintint),
	CONSTRAINT FK_Intervention_Intervenant FOREIGN KEY (codint) REFERENCES logiclim.dbo.Intervenant(codint),
	CONSTRAINT FK_Intervention_Panne FOREIGN KEY (codpan) REFERENCES logiclim.dbo.Panne(codpan),
	CONSTRAINT FK_Intervention_Site FOREIGN KEY (cptsit) REFERENCES logiclim.dbo.Site(cptsit)
);
 CREATE NONCLUSTERED INDEX IX_Intervention ON logiclim.dbo.Intervention (  codint ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX IX_Intervention_1 ON logiclim.dbo.Intervention (  codpan ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX IX_Intervention_2 ON logiclim.dbo.Intervention (  nummodres ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX IX_Intervention_3 ON logiclim.dbo.Intervention (  numdev ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX IX_Intervention_4 ON logiclim.dbo.Intervention (  numintint ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 80   ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX [_dta_index_Intervention_5_60861858__K3_1_4_6_8_20_25_26] ON logiclim.dbo.Intervention (  cptsit ASC  )  
	 INCLUDE ( codint , datheuapp , datheulim , datint , datintpre , numintint , staint ) 
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_22_21 ON logiclim.dbo.Intervention (  staint ASC  )  
	 INCLUDE ( cptsit , datint , typint ) 
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_28_27 ON logiclim.dbo.Intervention (  cptsit ASC  )  
	 INCLUDE ( codint , datint , datintpre , numintint , staint , typint ) 
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_2_1 ON logiclim.dbo.Intervention (  cptsit ASC  )  
	 INCLUDE ( codint , datheulim , datint , datintpre , numintint , staint , typint ) 
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_35_34 ON logiclim.dbo.Intervention (  cptsit ASC  )  
	 INCLUDE ( codint , datint , datintpre , numintint , staint ) 
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_43_42 ON logiclim.dbo.Intervention (  typint ASC  , staint ASC  )  
	 INCLUDE ( cptsit , numintint ) 
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_4_3 ON logiclim.dbo.Intervention (  cptsit ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_64_63 ON logiclim.dbo.Intervention (  cptsit ASC  , staint ASC  )  
	 INCLUDE ( codint , datheulim , datint , datintpre , numintint , typint ) 
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX missing_index_8_7 ON logiclim.dbo.Intervention (  cptsit ASC  , staint ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;


-- logiclim.dbo.InterventionFicheFluide definition

-- Drop table

-- DROP TABLE logiclim.dbo.InterventionFicheFluide;

CREATE TABLE logiclim.dbo.InterventionFicheFluide (
	numintficflu int IDENTITY(1,1) NOT NULL,
	numint varchar(50) COLLATE French_CI_AS NOT NULL,
	numficflu varchar(50) COLLATE French_CI_AS NOT NULL,
	datficflu datetime NOT NULL,
	cptsit int NULL,
	CONSTRAINT PK_InterventionFicheFluide PRIMARY KEY (numintficflu),
	CONSTRAINT FK_InterventionFicheFluide_Site FOREIGN KEY (cptsit) REFERENCES logiclim.dbo.Site(cptsit)
);


-- logiclim.dbo.InterventionFourniture definition

-- Drop table

-- DROP TABLE logiclim.dbo.InterventionFourniture;

CREATE TABLE logiclim.dbo.InterventionFourniture (
	numintfou int IDENTITY(1,1) NOT NULL,
	numint int NULL,
	qtefou float NULL,
	libfou nvarchar(255) COLLATE French_CI_AS NULL,
	creele datetime DEFAULT getdate() NULL,
	majle datetime NULL,
	CONSTRAINT PK_InterventionFourniture PRIMARY KEY (numintfou),
	CONSTRAINT FK_InterventionFourniture_Intervention FOREIGN KEY (numint) REFERENCES logiclim.dbo.Intervention(numintint)
);


-- logiclim.dbo.ParametreRepertoireTechnique definition

-- Drop table

-- DROP TABLE logiclim.dbo.ParametreRepertoireTechnique;

CREATE TABLE logiclim.dbo.ParametreRepertoireTechnique (
	nummod int NOT NULL,
	numcha int NOT NULL,
	visibi bit DEFAULT 0 NOT NULL,
	CONSTRAINT PK_ParametreRepertoireTechnique PRIMARY KEY (nummod,numcha),
	CONSTRAINT FK_ParametreRepertoireTechnique_ChampRepertoireTechnique FOREIGN KEY (numcha) REFERENCES logiclim.dbo.ChampRepertoireTechnique(numcha),
	CONSTRAINT FK_ParametreRepertoireTechnique_ModeleRepertoireTechnique FOREIGN KEY (nummod) REFERENCES logiclim.dbo.ModeleRepertoireTechnique(nummod) ON DELETE CASCADE
);
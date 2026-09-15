-- Référentiels du domaine ClimAccess. Schéma seul : les valeurs issues de
-- legacy/referentiels.txt sont chargées par 20260915120009_seed_referentiels.sql.
-- Les valeurs fixes (non présentes dans le dump source) sont chargées ici directement.

create table if not exists public.activites (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.activites is 'Source : Activites (Numactivite, Nomactivite).';
select public.apply_set_updated_at('activites');

create table if not exists public.modes_resolution (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.modes_resolution is 'Source : ModeResolution. Historique.';
select public.apply_set_updated_at('modes_resolution');

create table if not exists public.pannes (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text,
  famille text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.pannes is 'Source : Panne. Codes 47..50 (NULL en source) ignorés ; code 41 (NULL en source) conservé avec le libellé "Non renseignée".';
comment on column public.pannes.famille is 'Préfixe du libellé avant le premier "-" (Clim, VMC, RAC, Destrat, Chambre froide…).';
select public.apply_set_updated_at('pannes');

create table if not exists public.societes (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text,
  est_fmc boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.societes is 'Source : Societe. est_fmc = true pour les codes 1, 111, 112, 113 (cf. CLAUDE.md / brief étape 1).';
select public.apply_set_updated_at('societes');

create table if not exists public.sous_types_intervention (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.sous_types_intervention is 'Source : SousType (= nature technique).';
select public.apply_set_updated_at('sous_types_intervention');

create table if not exists public.statuts_intervention (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text not null,
  ordre_affichage integer not null default 0,
  actif boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.statuts_intervention is 'Source : StatusInterv. code = IndexLigne (valeur métier posée explicitement en source, pas une identité séquentielle). Codes historiques 3,4,5,6 chargés avec actif=false.';
select public.apply_set_updated_at('statuts_intervention');

create table if not exists public.statuts_facturation (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text not null,
  ordre_affichage integer not null default 0,
  reserve_admin boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.statuts_facturation is 'Source : StatutFacture. code = IndexLigne.';
comment on column public.statuts_facturation.reserve_admin is 'Doit correspondre à StatutFacture.QueKadi ; absent de legacy/referentiels.txt fourni à l''étape 1, laissé à false partout, à corriger à l''étape 2 depuis la colonne source.';
select public.apply_set_updated_at('statuts_facturation');

create table if not exists public.familles_gaz (
  id bigint generated always as identity primary key,
  code smallint not null unique,
  libelle text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.familles_gaz is 'Source : Liste_Type_Gaz (HCFC, HFC, HFO ; "HF0" corrigé en "HFO"). Codes 1/2/3 attribués ici faute de dump source : à recaler sur Liste_Type_Gaz.id réel à l''étape 2.';
select public.apply_set_updated_at('familles_gaz');

create table if not exists public.types_fluide (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text not null,
  gwp integer,
  famille_gaz_id bigint references public.familles_gaz(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.types_fluide is 'Source : TypeFluide. legacy/referentiels.txt ne fournit pas TypeFluide.Type (famille de gaz) : famille_gaz_id est déduit ici de la chimie connue du fluide, à vérifier à l''étape 2 contre la colonne source.';
select public.apply_set_updated_at('types_fluide');

create table if not exists public.types_intervention (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text not null,
  ordre_affichage integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.types_intervention is 'Source : TypeInterv. code = IndexLigne. Code 0 "Toutes" non chargé.';
select public.apply_set_updated_at('types_intervention');

create table if not exists public.marques (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.marques is 'Source : Marque. Aucune donnée dans legacy/referentiels.txt : table vide, peuplée à l''étape 2.';
select public.apply_set_updated_at('marques');

create table if not exists public.reperes (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text,
  controle_etancheite boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.reperes is 'Source : Repere (id, Repere, CtrlEtancheite). Aucune donnée dans legacy/referentiels.txt : table vide, peuplée à l''étape 2.';
select public.apply_set_updated_at('reperes');

create table if not exists public.types_telecommande (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.types_telecommande is 'Source : TypeTel. Aucune donnée dans legacy/referentiels.txt : table vide, peuplée à l''étape 2.';
select public.apply_set_updated_at('types_telecommande');

create table if not exists public.types_equipement (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text not null,
  famille smallint,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.types_equipement is 'Source : TypeAudit (renommée). famille = chiffre avant le premier "-" du libellé.';
select public.apply_set_updated_at('types_equipement');

create table if not exists public.zones_geographiques (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.zones_geographiques is 'Source : ZoneGeographique (numzon, nomzon).';
select public.apply_set_updated_at('zones_geographiques');

create table if not exists public.jours_feries (
  id bigint generated always as identity primary key,
  date_jour date not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.jours_feries is 'Source : JoursFeries (datjoufer). Aucune donnée dans legacy/referentiels.txt : table vide, peuplée à l''étape 2.';
select public.apply_set_updated_at('jours_feries');

create table if not exists public.ecarts_visites (
  id bigint generated always as identity primary key,
  nombre_visites smallint not null unique,
  ecart_jours integer,
  commentaire text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.ecarts_visites is 'Source : VisitesMaint (Nombre_Visites, Ecart_Permis_Jour, Commentaire). Unité/valeur de ecart_jours à confirmer à l''étape 2 contre la colonne source Ecart_Permis_Jour.';
select public.apply_set_updated_at('ecarts_visites');

create table if not exists public.types_evenement_vehicule (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.types_evenement_vehicule is 'Source : ListeEVVehicule. Aucune donnée dans legacy/referentiels.txt : table vide, peuplée à l''étape 2.';
select public.apply_set_updated_at('types_evenement_vehicule');

create table if not exists public.etats_vehicule (
  id bigint generated always as identity primary key,
  code integer not null unique,
  libelle text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.etats_vehicule is 'Source : ListeEtatVehicule (code 4 = vendu). Aucune donnée dans legacy/referentiels.txt : table vide, peuplée à l''étape 2.';
select public.apply_set_updated_at('etats_vehicule');

create table if not exists public.natures_visite (
  id bigint generated always as identity primary key,
  code smallint not null unique,
  libelle text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.natures_visite is 'Valeurs fixes (natureintervention) : 1 technique, 2 filtres, 3 maintenance générale.';
select public.apply_set_updated_at('natures_visite');

insert into public.natures_visite (code, libelle) values
  (1, 'Visite technique'),
  (2, 'Visite filtres'),
  (3, 'Visite maintenance générale')
on conflict (code) do nothing;

create table if not exists public.references_materiel (
  id bigint generated always as identity primary key,
  legacy_id integer unique,
  reference text,
  repere text,
  type_equipement text,
  marque_id bigint references public.marques(id) on delete restrict,
  fluide_id bigint references public.types_fluide(id) on delete restrict,
  type_telecommande text,
  reversible text,
  resistance text,
  puissance_frigo numeric,
  puissance_frigo_brut text,
  puissance_calo numeric,
  puissance_calo_brut text,
  quantite_gaz text,
  nombre_filtres text,
  dimension_filtres text,
  nombre_courroies text,
  reference_courroies text,
  appoint_roof text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.references_materiel is 'Catalogue. Source : Reference (764 modèles). Aucune donnée dans legacy/referentiels.txt : table vide, peuplée à l''étape 2. Nommar -> marque_id, Fluide -> fluide_id (résolus par libellé au transfert).';
select public.apply_set_updated_at('references_materiel');

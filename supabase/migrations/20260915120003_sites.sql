-- Sites (magasins), contrats, horaires, matériel, registre de sécurité.

create table if not exists public.sites (
  id bigint generated always as identity primary key,
  legacy_id integer unique,
  numero_magasin integer,
  client_id bigint not null references public.clients(id) on delete restrict,
  code_client text,
  nom text,
  nom_societe text,
  situation text,
  type_site text,
  adresse text,
  code_postal text,
  ville text,
  telephone text,
  fax text,
  email text,
  responsable_civilite text,
  responsable_nom text,
  responsable_prenom text,
  telephone_centre_commercial text,
  zone_id bigint references public.zones_geographiques(id) on delete restrict,
  zone_secondaire_id bigint references public.zones_geographiques(id) on delete restrict,
  intervenant_id bigint references public.intervenants(id) on delete restrict,
  donneur_ordre_id bigint references public.donneurs_ordre(id) on delete restrict,
  surface_vente numeric,
  surface_totale numeric,
  visites_entretien_par_an smallint,
  nombre_desenfumage smallint,
  date_derniere_visite_desenfumage timestamptz,
  commentaire_general text,
  commentaire_divers text,
  descriptif_investissement text,
  investissement boolean not null default false,
  date_creation_site_brut text,
  particulier boolean not null default false,
  indice_qualite smallint,
  indice_vetuste smallint,
  indice_puissance smallint,
  indice_accessibilite smallint,
  nombre_plans smallint,
  nombre_photos smallint,
  allumage_clim boolean not null default false,
  gtb boolean not null default false,
  fluide_id bigint references public.types_fluide(id) on delete restrict,
  temperature_entree text,
  temperature_sortie text,
  longitude numeric(9,6),
  latitude numeric(9,6),
  precision_geo text,
  dossier_chemin text,
  date_mise_en_service date,
  garantie_pieces_mo_annees smallint,
  garantie_pieces_annees smallint,
  garantie_compresseur_annees smallint,
  date_prise_en_charge timestamptz,
  date_derniere_visite_entretien timestamptz,
  photo_a_faire boolean not null default false,
  photo_faite boolean not null default false,
  audit_a_faire boolean not null default false,
  audit_fait boolean not null default false,
  controle_etancheite_a_faire boolean not null default false,
  controle_etancheite_fait boolean not null default false,
  detection_fuite_permanente boolean not null default false,
  resume_devis_html text,
  numero_esabora text,
  tarifs_specifiques boolean not null default false,
  tarif_heure_mo numeric,
  tarif_deplacement numeric,
  rdv_a_prendre boolean not null default false,
  ferme boolean not null default false,
  date_fermeture date,
  motif_fermeture text,
  ne_plus_intervenir boolean not null default false,
  retard_paiement boolean not null default false,
  nacelle_necessaire boolean not null default false,
  arret_urgence_clim_oui boolean not null default false,
  arret_urgence_clim_non boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.sites is 'Source : Site. datesignaturecontrat/numerocontratclient repris dans site_contrats, pas ici.';
comment on column public.sites.numero_magasin is 'Source : numsit (non unique, indexé).';
comment on column public.sites.particulier is 'Colonne détournée source : demixasit.';
comment on column public.sites.ne_plus_intervenir is 'Colonne détournée source : majregistresecuritefait.';
comment on column public.sites.retard_paiement is 'Colonne détournée source : misajoursecurite.';
comment on column public.sites.nacelle_necessaire is 'Colonne détournée source : majregistresecuriteafaire.';
comment on column public.sites.arret_urgence_clim_oui is 'Colonne détournée source : aspirateur.';
comment on column public.sites.arret_urgence_clim_non is 'Colonne détournée source : accessfiltre.';
comment on column public.sites.detection_fuite_permanente is 'Source : controleetancheiteponctuel.';
comment on column public.sites.visites_entretien_par_an is 'Source : nbrentsit. Donnée pivot de la planification, conservée en plus de site_contrats.visites_par_an.';
select public.apply_set_updated_at('sites');

create index if not exists sites_client_id_idx on public.sites (client_id);
create index if not exists sites_numero_magasin_idx on public.sites (numero_magasin);
create index if not exists sites_zone_id_idx on public.sites (zone_id);
create index if not exists sites_intervenant_id_idx on public.sites (intervenant_id);
create index if not exists sites_donneur_ordre_id_idx on public.sites (donneur_ordre_id);

create table if not exists public.site_contrats (
  id bigint generated always as identity primary key,
  site_id bigint not null references public.sites(id) on delete cascade,
  lot text not null check (lot in ('clim','chaudiere','desenfumage')),
  numero_contrat text,
  date_contrat date,
  visites_par_an smallint,
  redevance numeric,
  redevance_secondaire numeric,
  visites_secondaires smallint,
  sous_traitant_id bigint references public.intervenants(id) on delete restrict,
  tarif_sous_traitant numeric,
  date_signature date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (site_id, lot)
);
comment on table public.site_contrats is 'Un lot (clim/chaudiere/desenfumage) par ligne, créée seulement si au moins une colonne du lot est renseignée en source. Clim : numerocontratclient, datprisencharge, nbrentsit, mntredev, montantredevancefiltre, nombrevisitefiltre, nombrevisitetechnique (-> visites_secondaires si filtre null), montantredevancetechnique (remplace mntredev si non null), NumSousTraitClim, TarifSousTraitClim, datesignaturecontrat. Chaudière : NumContratChaudiere, DateContratChaudiere, NombreContratChaudiere, mntredevContratChaudiere, NumSousTraitChaudiere, TarifSousTraitChaudiere. Désenfumage : numerocontratdesenfumage, datedesenfumage, nombrevisitedesenfumage, montantredevancedesenfumage, NumSousTraitDesenfum, TarifSousTraitDesenfum.';
create index if not exists site_contrats_site_id_idx on public.site_contrats (site_id);
create index if not exists site_contrats_sous_traitant_id_idx on public.site_contrats (sous_traitant_id);
select public.apply_set_updated_at('site_contrats');

create table if not exists public.site_horaires (
  id bigint generated always as identity primary key,
  site_id bigint not null references public.sites(id) on delete cascade,
  jour smallint not null check (jour between 1 and 7),
  ouverture time,
  fermeture time,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (site_id, jour)
);
comment on table public.site_horaires is 'Source : hor_lun_ouv..hor_dim_fer (varchar "HH:MM", null si vide ou "00:00"). jour : 1 lundi .. 7 dimanche.';
create index if not exists site_horaires_site_id_idx on public.site_horaires (site_id);
select public.apply_set_updated_at('site_horaires');

create table if not exists public.site_materiels (
  id bigint generated always as identity primary key,
  legacy_id integer unique,
  site_id bigint references public.sites(id) on delete cascade,
  repere_sur_site smallint,
  repere text,
  emplacement text,
  quantite smallint,
  marque text,
  type_equipement text,
  reference text,
  numero_serie text,
  reversible text,
  resistance_electrique text,
  puissance_frigo_w numeric,
  puissance_calo_w numeric,
  fluide_libelle text,
  fluide_id bigint references public.types_fluide(id) on delete restrict,
  charge_fluide_kg numeric,
  date_mise_en_service_brut text,
  date_mise_en_service date,
  type_telecommande text,
  nombre_telecommandes smallint,
  emplacement_telecommande text,
  disjoncteur_general text,
  disjoncteur_principal text,
  disjoncteur_armoire_principale text,
  disjoncteur_coffret_independant text,
  accessibilite_groupe text,
  accessibilite_cassettes text,
  support_groupes text,
  etat_supports smallint,
  rooftop_nombre_filtres smallint,
  rooftop_reference_filtres text,
  rooftop_nombre_courroies smallint,
  rooftop_reference_courroies text,
  rooftop_appoint_chauffage text,
  aerotherme_nombre text,
  aerotherme_gaz_elec text,
  rideau_air boolean not null default false,
  rideau_air_nombre_type text,
  rideau_air_puissance text,
  rideau_air_disjoncteur text,
  sas_entree boolean not null default false,
  clim_locaux_sociaux_emplacement text,
  clim_locaux_sociaux_emplacement_groupe_exterieur text,
  clim_locaux_sociaux_marque text,
  clim_locaux_sociaux_type text,
  clim_locaux_sociaux_reference text,
  clim_locaux_sociaux_numero_serie text,
  clim_locaux_sociaux_date_mise_service text,
  clim_locaux_sociaux_reversible boolean not null default false,
  clim_locaux_sociaux_fluide_quantite text,
  radiateurs boolean not null default false,
  radiateurs_localisation text,
  radiateurs_disjoncteur text,
  vmc boolean not null default false,
  vmc_localisation text,
  photos boolean not null default false,
  rapports_maintenance text,
  devis_en_cours text,
  devis_valide text,
  controle_etancheite_libelle text,
  observations text,
  date_controle_etancheite date,
  certificat_etancheite_edite boolean not null default false,
  intervention_id bigint,
  date_achat date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.site_materiels is 'Source : SiteMateriel. Repere (texte) référence reperes.libelle sans FK déclarée (souple).';
comment on column public.site_materiels.fluide_libelle is 'Colonne détournée source : FluideQuantite.';
comment on column public.site_materiels.charge_fluide_kg is 'Colonne détournée source : NbreRadiateurs (piège de migration connu, cf CONTEXTE.md).';
comment on column public.site_materiels.intervention_id is 'Source : NumeroInter. FK vers interventions ajoutée dans 20260915120004_interventions.sql (créée après cette table).';
create index if not exists site_materiels_site_id_idx on public.site_materiels (site_id);
create index if not exists site_materiels_fluide_id_idx on public.site_materiels (fluide_id);
select public.apply_set_updated_at('site_materiels');

create table if not exists public.site_registre_securite (
  id bigint generated always as identity primary key,
  legacy_id integer unique,
  site_id bigint not null references public.sites(id) on delete cascade,
  date_mise_a_jour timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.site_registre_securite is 'Source : SiteMAJRegistre ([N°], cptsit, [Date]).';
create index if not exists site_registre_securite_site_id_idx on public.site_registre_securite (site_id);
select public.apply_set_updated_at('site_registre_securite');

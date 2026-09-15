-- Interventions : cœur métier de l'application.

create table if not exists public.interventions (
  id bigint generated always as identity primary key,
  legacy_id integer unique,
  numero_bon integer,
  site_id bigint not null references public.sites(id) on delete restrict,
  intervenant_id bigint references public.intervenants(id) on delete restrict,
  type_code integer references public.types_intervention(code) on delete restrict,
  type_brut text,
  statut_code integer references public.statuts_intervention(code) on delete restrict,
  nature_visite_code smallint references public.natures_visite(code) on delete restrict,
  date_demande timestamptz,
  date_limite timestamptz,
  date_prevue timestamptz,
  heure_prevue time,
  date_realisee timestamptz,
  heure_arrivee time,
  heure_depart time,
  temps_aller interval,
  temps_retour interval,
  date_retour_fiche timestamptz,
  objet text,
  commentaire_interne text,
  directives text,
  commentaire_post_intervention text,
  commentaire_technicien text,
  reference_interne text,
  reference_client text,
  chemin_di_client text,
  chemin_bon_pdf text,
  chemin_dossier_etancheite text,
  contact_id bigint references public.contacts(id) on delete set null,
  panne_code integer references public.pannes(code) on delete restrict,
  panne_origine_externe boolean not null default false,
  charge_affaire_id bigint references public.utilisateurs(id) on delete set null,
  saisi_par_id bigint references public.utilisateurs(id) on delete set null,
  prediag_par_id bigint references public.utilisateurs(id) on delete set null,
  prediag_resolu boolean not null default false,
  envoye_sous_traitant_par_id bigint references public.utilisateurs(id) on delete set null,
  numero_demande_sous_traitant text,
  technicien_prevu_id bigint references public.utilisateurs(id) on delete set null,
  nombre_techniciens smallint,
  retour_fiche_original boolean not null default false,
  retour_fiche_copie boolean not null default false,
  retour_fiche_numerique boolean not null default false,
  registre_securite_mis_a_jour boolean not null default false,
  controle_etancheite_annuel boolean not null default false,
  controle_etancheite_ponctuel boolean not null default false,
  photo_faite boolean not null default false,
  audit_fait boolean not null default false,
  masquer_heures_sur_bon boolean not null default false,
  visite_gratuite boolean not null default false,
  devis_a_faire boolean not null default false,
  devis_fait boolean not null default false,
  devis_ne_sera_pas_fait boolean not null default false,
  commentaire_devis text,
  commentaire_devis_interne text,
  numero_devis_accepte text,
  numero_devis_legacy text,
  duplicata_traite boolean not null default false,
  non_facturable boolean not null default false,
  facturee_legacy boolean not null default false,
  montant_facture_legacy numeric,
  montant_fmc numeric,
  montant_sous_traitant numeric,
  rappel_24h boolean not null default false,
  rappel_48h boolean not null default false,
  rappel_72h boolean not null default false,
  rappel_semaine boolean not null default false,
  date_dernier_rappel timestamptz,
  signature_site_image text,
  signature_client_image text,
  signature_technicien_image text,
  signature_site_nom text,
  signature_client_nom text,
  signature_technicien_nom text,
  signature_technicien_json jsonb,
  signature_client_json jsonb,
  signature_site_base64 text,
  statut_facturation_code integer references public.statuts_facturation(code) on delete restrict,
  sous_type_code integer references public.sous_types_intervention(code) on delete restrict,
  minutes_telephone integer,
  urgence_devis smallint,
  duplicata_traite_par_id bigint references public.utilisateurs(id) on delete set null,
  priorite integer,
  noms_techniciens text,
  quantite_gaz_kg numeric,
  fluide_id integer references public.types_fluide(code) on delete restrict,
  heures_vendues numeric,
  location_nacelle boolean not null default false,
  horodatage_prediag text,
  prestations_realisees text,
  commentaire_cloture_panne text,
  chemin_facture_fmc text,
  chemin_facture_sous_traitant text,
  date_facturation date,
  montant_ht_devis_accepte numeric,
  numero_contrat_client text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.interventions is 'Source : Intervention. Ignorés : classeepar, duplicatacreepar, RV (rowversion SQL Server, remplacé par updated_at).';
comment on column public.interventions.type_code is 'Source : typint (converti en entier). Valeurs non numériques -> null + type_brut.';
comment on column public.interventions.statut_facturation_code is 'Colonne détournée source : nbrappint.';
comment on column public.interventions.sous_type_code is 'Colonne détournée source : imprimeepar.';
comment on column public.interventions.minutes_telephone is 'Colonne détournée source : retourficheinterventionpar.';
comment on column public.interventions.urgence_devis is 'Colonne détournée source : devisepar (1 faible, 2 moyenne, 3 forte).';
comment on column public.interventions.duplicata_traite_par_id is 'Colonne détournée source : stadev.';
comment on column public.interventions.priorite is 'Colonne détournée source : numpartenaire.';
comment on column public.interventions.noms_techniciens is 'Colonne détournée source : numdevpartenaire.';
comment on column public.interventions.quantite_gaz_kg is 'Colonne détournée source : mnthtdevis.';
comment on column public.interventions.fluide_id is 'Colonne détournée source : nummodres. FK types_fluide par code (pas par id).';
comment on column public.interventions.heures_vendues is 'Colonne détournée source : nbrpagfax.';
comment on column public.interventions.location_nacelle is 'Colonne détournée source : intafact.';
comment on column public.interventions.horodatage_prediag is 'Colonne détournée source : numerocommande.';
comment on column public.interventions.prestations_realisees is 'Colonne détournée source : sigsit.';
comment on column public.interventions.commentaire_cloture_panne is 'Colonne détournée source : sigtec.';
comment on column public.interventions.chemin_facture_fmc is 'Colonne détournée source : sigcli.';
comment on column public.interventions.chemin_facture_sous_traitant is 'Colonne détournée source : commajregsec.';
comment on column public.interventions.date_facturation is 'Colonne détournée source : datesignaturecontrat.';
comment on column public.interventions.montant_ht_devis_accepte is 'Colonne détournée source : mnthtdevpartenaire.';
comment on column public.interventions.numero_contrat_client is 'Colonne détournée source : numerocontratclient.';

create index if not exists interventions_site_id_idx on public.interventions (site_id);
create index if not exists interventions_statut_code_idx on public.interventions (statut_code);
create index if not exists interventions_type_code_idx on public.interventions (type_code);
create index if not exists interventions_intervenant_id_idx on public.interventions (intervenant_id);
create index if not exists interventions_date_limite_idx on public.interventions (date_limite);
create index if not exists interventions_date_realisee_idx on public.interventions (date_realisee);
create index if not exists interventions_reference_client_idx on public.interventions (reference_client);
create index if not exists interventions_numero_bon_idx on public.interventions (numero_bon);
create index if not exists interventions_statut_facturation_code_idx on public.interventions (statut_facturation_code);

select public.apply_set_updated_at('interventions');

-- FK différée : site_materiels a été créée avant interventions (voir 20260915120003_sites.sql).
select public.add_constraint_if_not_exists(
  'site_materiels',
  'site_materiels_intervention_id_fkey',
  'foreign key (intervention_id) references public.interventions(id) on delete set null'
);

create table if not exists public.intervention_techniciens (
  id bigint generated always as identity primary key,
  legacy_id integer unique,
  intervention_id bigint not null references public.interventions(id) on delete cascade,
  utilisateur_id bigint references public.utilisateurs(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.intervention_techniciens is 'Source : InterventionTechnicien (numintuti, numintint, numuti). Colonne numint ignorée (redondante).';
create index if not exists intervention_techniciens_intervention_id_idx on public.intervention_techniciens (intervention_id);
create index if not exists intervention_techniciens_utilisateur_id_idx on public.intervention_techniciens (utilisateur_id);
select public.apply_set_updated_at('intervention_techniciens');

create table if not exists public.fiches_intervention (
  id bigint generated always as identity primary key,
  legacy_id integer unique,
  intervention_id bigint references public.interventions(id) on delete cascade,
  numero_bon integer,
  date_fiche timestamptz,
  heure_debut time,
  heure_fin time,
  temps_aller_h numeric,
  temps_retour_h numeric,
  remarques text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.fiches_intervention is 'Source : FicheIntervention. ficheInt1..4 ignorés (non exploités).';
create index if not exists fiches_intervention_intervention_id_idx on public.fiches_intervention (intervention_id);
select public.apply_set_updated_at('fiches_intervention');

create table if not exists public.heures_techniciens (
  id bigint generated always as identity primary key,
  legacy_id integer unique,
  utilisateur_id bigint references public.utilisateurs(id) on delete restrict,
  type_code integer,
  intervention_numero_bon integer,
  libelle text,
  date_travail date,
  heure_debut time,
  heure_fin time,
  heure_debut_fmc time,
  heure_fin_fmc time,
  verrouille boolean not null default false,
  site_id bigint references public.sites(id) on delete restrict,
  date_saisie timestamptz,
  ne_pas_comptabiliser boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.heures_techniciens is 'Source : HeuresTech (HeuresTechAuto ignorée, cache plafonné). TypeInterv = 60 -> relevé km, garder le code brut.';
comment on column public.heures_techniciens.intervention_numero_bon is 'Source : NumInterv. Clé = numéro de bon (Intervention.numint), pas legacy_id : à résoudre vers interventions.id à l''étape 2.';
create index if not exists heures_techniciens_utilisateur_id_idx on public.heures_techniciens (utilisateur_id);
create index if not exists heures_techniciens_site_id_idx on public.heures_techniciens (site_id);
select public.apply_set_updated_at('heures_techniciens');

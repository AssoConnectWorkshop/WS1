-- Tiers : clients, donneurs d'ordre, contacts, intervenants, utilisateurs.

create table if not exists public.clients (
  id bigint generated always as identity primary key,
  legacy_id integer unique,
  nom text not null unique,
  adresse text,
  code_postal text,
  ville text,
  telephone text,
  fax text,
  contact_principal text,
  email text,
  delai_intervention_heures numeric,
  numero_esabora_maint text,
  numero_esabora_clim text,
  actif boolean not null default true,
  tarif_heure_mo numeric,
  tarif_deplacement numeric,
  est_client_fermeture boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.clients is 'Source : Client. logcli (logo, type image) ignoré, à migrer vers Storage plus tard.';
comment on column public.clients.numero_esabora_maint is 'Colonne détournée source : cheminpho.';
comment on column public.clients.numero_esabora_clim is 'Colonne détournée source : cheminpla.';
comment on column public.clients.actif is 'Source : affcli.';
comment on column public.clients.est_client_fermeture is 'true pour le client legacy 368 "client fermé" (Site.fermeture les rattache à ce client).';
select public.apply_set_updated_at('clients');

create table if not exists public.donneurs_ordre (
  id bigint generated always as identity primary key,
  legacy_id integer unique,
  nom text,
  adresse text,
  code_postal text,
  ville text,
  telephone text,
  fax text,
  contact_principal text,
  email text,
  delai_intervention_heures numeric,
  logo_chemin text,
  pied_page_ligne_1 text,
  pied_page_ligne_2 text,
  pied_page_ligne_3 text,
  actif boolean not null default true,
  saisie_simplifiee_tablette boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.donneurs_ordre is 'Source : Donneur. logdonneur (logo, type image) ignoré.';
comment on column public.donneurs_ordre.pied_page_ligne_1 is 'Colonne détournée source : meldonneur.';
comment on column public.donneurs_ordre.pied_page_ligne_2 is 'Colonne détournée source : cheminpho (double usage, aussi logo_chemin).';
comment on column public.donneurs_ordre.pied_page_ligne_3 is 'Colonne détournée source : cheminpla.';
comment on column public.donneurs_ordre.logo_chemin is 'Colonne détournée source : cheminpho.';
comment on column public.donneurs_ordre.actif is 'Source : affdonneur.';
comment on column public.donneurs_ordre.saisie_simplifiee_tablette is 'Source : sairapdonneur.';
select public.apply_set_updated_at('donneurs_ordre');

create table if not exists public.contacts (
  id bigint generated always as identity primary key,
  legacy_code text unique,
  nom text,
  prenom text,
  civilite text,
  client_id bigint references public.clients(id) on delete restrict,
  donneur_ordre_id bigint references public.donneurs_ordre(id) on delete restrict,
  email text,
  telephone text,
  fax text,
  mobile text,
  fonction text,
  observations text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.contacts is 'Source : Contact. legacy_code = codcon (clé source, texte).';
create index if not exists contacts_client_id_idx on public.contacts (client_id);
create index if not exists contacts_donneur_ordre_id_idx on public.contacts (donneur_ordre_id);
select public.apply_set_updated_at('contacts');

create table if not exists public.intervenants (
  id bigint generated always as identity primary key,
  legacy_id integer unique,
  code text not null unique,
  nom text,
  adresse text,
  code_postal text,
  ville text,
  telephone text,
  fax text,
  email text,
  dirigeant_nom text,
  dirigeant_telephone text,
  dirigeant_email text,
  interlocuteur_nom text,
  interlocuteur_telephone text,
  informations text,
  historique_fmc text,
  villes_codes_postaux text,
  latitude numeric(9,6),
  longitude numeric(9,6),
  precision_geo text,
  provenance text,
  interlocuteur_fmc_id bigint,
  cree_par_id bigint,
  note_maintenance smallint,
  note_depannage smallint,
  note_travaux smallint,
  note_reactivite smallint,
  dossier_chemin text,
  motif_ne_plus_intervenir text,
  est_technicien_interne boolean not null default false,
  ne_plus_intervenir boolean not null default false,
  est_prospect boolean not null default false,
  est_sous_traitant boolean not null default false,
  est_sous_traitant_ponctuel boolean not null default false,
  peut_maintenance boolean not null default false,
  peut_depannage boolean not null default false,
  peut_travaux boolean not null default false,
  confie_maintenance boolean not null default false,
  confie_depannage boolean not null default false,
  confie_travaux boolean not null default false,
  zone_nationale boolean not null default false,
  email_facturation text,
  site_internet text,
  n_existe_plus boolean not null default false,
  autoliquidation boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.intervenants is 'Source : Intervenant. code = codint (« FMC » = interne, sinon sous-traitant). Rooftop_Interv ignoré (cassé en source).';
comment on column public.intervenants.interlocuteur_fmc_id is 'Source : ChargeAffaireFMC_Interv. FK vers utilisateurs ajoutée plus bas (utilisateurs est créée après, dans ce même fichier).';
comment on column public.intervenants.cree_par_id is 'Source : CreePar_Interv. FK vers utilisateurs ajoutée plus bas.';
select public.apply_set_updated_at('intervenants');

create index if not exists intervenants_code_idx on public.intervenants (code);

create table if not exists public.intervenant_zones (
  id bigint generated always as identity primary key,
  intervenant_id bigint not null references public.intervenants(id) on delete cascade,
  zone_id bigint references public.zones_geographiques(id) on delete restrict,
  rang smallint not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (intervenant_id, rang)
);
comment on table public.intervenant_zones is 'Source : Intervenant.numzonint (rang 1), numzonint_2/3/4_Interv (rangs 2 à 4).';
create index if not exists intervenant_zones_zone_id_idx on public.intervenant_zones (zone_id);
select public.apply_set_updated_at('intervenant_zones');

create table if not exists public.intervenant_activites (
  id bigint generated always as identity primary key,
  intervenant_id bigint not null references public.intervenants(id) on delete cascade,
  activite_id bigint references public.activites(id) on delete restrict,
  rang smallint not null,
  tarif_mo numeric,
  tarif_deplacement numeric,
  date_tarif date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (intervenant_id, rang)
);
comment on table public.intervenant_activites is 'Source : Intervenant.Activite_n / MO_Activite_n / Depl_Activite_n / Date_Activite_n (n = 1..6, ignorer si Activite_n est null).';
create index if not exists intervenant_activites_activite_id_idx on public.intervenant_activites (activite_id);
select public.apply_set_updated_at('intervenant_activites');

create table if not exists public.utilisateurs (
  id bigint generated always as identity primary key,
  legacy_id integer unique,
  nom text,
  prenom text,
  login_legacy text,
  code_intervenant text references public.intervenants(code) on delete set null,
  profil smallint,
  societe_libelle_legacy text,
  societe_id bigint references public.societes(id) on delete restrict,
  email text,
  km_a_renseigner boolean not null default false,
  immatriculation text,
  auth_user_id uuid unique references auth.users(id) on delete set null,
  role text check (role in ('gestionnaire','administrateur')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.utilisateurs is 'Source : Utilisateur. mdputi (mot de passe en clair) volontairement ignoré : remplacé par Supabase Auth.';
comment on column public.utilisateurs.code_intervenant is 'Source : codintuti. Ne garder la valeur que si elle existe dans intervenants.code (sinon d''anciens mots de passe web s''y trouvent) : null sinon, contrôlé à l''étape 2.';
comment on column public.utilisateurs.profil is 'Source : typuti. 1 gestionnaire, 2 technicien, 3 gestionnaire (tech).';
comment on column public.utilisateurs.auth_user_id is 'Rattachement à Supabase Auth, posé à l''étape 3 (invitation). Null jusque-là.';
select public.apply_set_updated_at('utilisateurs');

create index if not exists utilisateurs_code_intervenant_idx on public.utilisateurs (code_intervenant);
create index if not exists utilisateurs_societe_id_idx on public.utilisateurs (societe_id);

select public.add_constraint_if_not_exists(
  'intervenants',
  'intervenants_interlocuteur_fmc_id_fkey',
  'foreign key (interlocuteur_fmc_id) references public.utilisateurs(id) on delete set null'
);
select public.add_constraint_if_not_exists(
  'intervenants',
  'intervenants_cree_par_id_fkey',
  'foreign key (cree_par_id) references public.utilisateurs(id) on delete set null'
);

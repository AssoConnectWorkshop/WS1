-- Parc automobile.

create table if not exists public.vehicules (
  id bigint generated always as identity primary key,
  legacy_id integer unique,
  immatriculation text,
  etat_code smallint references public.etats_vehicule(code) on delete restrict,
  dernier_km integer,
  date_mise_en_circulation date,
  km_achat integer,
  km_entre_revisions integer,
  mois_entre_revisions smallint,
  dossier_chemin text,
  garantie boolean not null default false,
  garantie_km integer,
  garantie_mois integer,
  leasing boolean not null default false,
  leasing_km integer,
  leasing_mois smallint,
  leasing_date_fin date,
  conducteur_id bigint references public.utilisateurs(id) on delete set null,
  numero_telepeage text,
  carte_essence_code text,
  carte_essence_numero text,
  marque text,
  modele text,
  societe_vehicule smallint,
  crit_air boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.vehicules is 'Source : Vehicules.';
comment on column public.vehicules.dossier_chemin is 'Source : Champ_Libre.';
comment on column public.vehicules.societe_vehicule is '0 = FMC Clim, 1 = FMC Maintenance (Vehicules.Societe, distinct de societes.id/code).';
create index if not exists vehicules_conducteur_id_idx on public.vehicules (conducteur_id);
select public.apply_set_updated_at('vehicules');

create table if not exists public.vehicule_evenements (
  id bigint generated always as identity primary key,
  legacy_id integer unique,
  vehicule_id bigint references public.vehicules(id) on delete cascade,
  date_evenement date not null,
  km integer not null,
  conducteur_id bigint references public.utilisateurs(id) on delete set null,
  immatriculation text,
  type_code smallint references public.types_evenement_vehicule(code) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.vehicule_evenements is 'Source : EvVehicules. vehicule_id résolu depuis Immat au transfert. Types : 0 import km, 1 et 5 relevé km, 2 révision, 3 CT, 4 contrôle complémentaire.';
create index if not exists vehicule_evenements_vehicule_id_idx on public.vehicule_evenements (vehicule_id);
select public.apply_set_updated_at('vehicule_evenements');

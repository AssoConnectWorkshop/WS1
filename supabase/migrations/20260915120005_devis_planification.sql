-- Devis (fusion des 3 tables source) et planification des visites.

create table if not exists public.statuts_devis (
  id bigint generated always as identity primary key,
  code smallint not null unique,
  libelle text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.statuts_devis is 'Valeurs fixes (StatutDevis) : 1 à viser, 2 visé/aucun retour, 3 annulé et remplacé, 4 envoyé, 5 refusé, 6 accepté.';
select public.apply_set_updated_at('statuts_devis');

insert into public.statuts_devis (code, libelle) values
  (1, 'À viser'),
  (2, 'Visé / aucun retour client'),
  (3, 'Annulé et remplacé'),
  (4, 'Envoyé'),
  (5, 'Refusé par le client'),
  (6, 'Accepté par le client')
on conflict (code) do nothing;

create table if not exists public.devis (
  id bigint generated always as identity primary key,
  legacy_id integer not null,
  famille text not null check (famille in ('sav','travaux','contrat')),
  numero text,
  statut_code smallint references public.statuts_devis(code) on delete restrict,
  fichier_chemin text,
  fichier_partenaire_chemin text,
  intervention_origine_id bigint references public.interventions(id) on delete set null,
  site_id bigint references public.sites(id) on delete restrict,
  client_id bigint references public.clients(id) on delete restrict,
  commentaire_client text,
  montant_fournitures numeric,
  heures_mo numeric,
  nombre_deplacements smallint,
  tarif_heure_mo numeric,
  tarif_deplacement numeric,
  montant_ht numeric,
  montant_ht_partenaire numeric,
  date_devis date,
  date_envoi date,
  envoye_par_id bigint references public.utilisateurs(id) on delete set null,
  partenaire_id bigint references public.intervenants(id) on delete set null,
  numero_devis_partenaire text,
  numero_commande text,
  type_panne_libelle text,
  quantite_materiel numeric,
  numero_devis_remplacement text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (famille, legacy_id)
);
comment on table public.devis is 'Fusion de Devis (famille sav), DevisTravaux (famille travaux), ContratDeMaintenance (famille contrat). legacy_id = NumeroDevis, pas unique seul sur cette table (exception à la règle générale) : unique (famille, legacy_id), car les trois tables source ont des identités qui se chevauchent.';
comment on column public.devis.numero is 'Source : NumeroDevisInterne.';
create index if not exists devis_site_id_idx on public.devis (site_id);
create index if not exists devis_client_id_idx on public.devis (client_id);
create index if not exists devis_intervention_origine_id_idx on public.devis (intervention_origine_id);
select public.apply_set_updated_at('devis');

create table if not exists public.planifications (
  id bigint generated always as identity primary key,
  legacy_id integer not null,
  client_id bigint references public.clients(id) on delete cascade,
  rang smallint not null check (rang between 1 and 12),
  date_limite date not null,
  nombre_visites smallint,
  recurrent boolean not null default false,
  date_fin_recurrence date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (legacy_id, rang)
);
comment on table public.planifications is 'Source : Planification. Une ligne par date : legacy_id = numeroplanification (non unique seul, colonnes T1..T12 éclatées en une ligne par rang non nulle) : unique (legacy_id, rang).';
create index if not exists planifications_client_id_idx on public.planifications (client_id);
select public.apply_set_updated_at('planifications');

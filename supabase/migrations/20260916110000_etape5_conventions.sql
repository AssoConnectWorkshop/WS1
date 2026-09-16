-- Étape 5 (écrans de saisie) : conventions transverses.
-- Suppression jamais physique pour interventions, sites, clients, devis (brief §Conventions) :
-- une colonne supprime_le, filtrée par les écrans plutôt qu'un vrai DELETE.
alter table public.interventions add column if not exists supprime_le timestamptz;
alter table public.sites add column if not exists supprime_le timestamptz;
alter table public.clients add column if not exists supprime_le timestamptz;
alter table public.devis add column if not exists supprime_le timestamptz;

-- Journal des modifications (interventions et devis pour cette étape, cf. brief §Conventions).
create table if not exists public.journal_modifications (
  id bigint generated always as identity primary key,
  "table" text not null,
  ligne_id bigint not null,
  utilisateur_id bigint references public.utilisateurs(id) on delete set null,
  date timestamptz not null default now(),
  diff jsonb not null
);
create index if not exists journal_modifications_table_ligne_idx on public.journal_modifications ("table", ligne_id);

comment on table public.journal_modifications is 'Historique des écritures faites par les Server Actions des interventions et devis (étape 5). Ajout seul : pas de colonne updated_at.';

-- RLS : table créée après la migration RLS générique de l'étape 1, on la reproduit ici.
-- Journal en ajout seul : aucune politique update/delete (refusé par défaut une fois RLS activée).
alter table public.journal_modifications enable row level security;

drop policy if exists select_authenticated on public.journal_modifications;
create policy select_authenticated on public.journal_modifications
  for select to authenticated using (true);

drop policy if exists write_utilisateurs on public.journal_modifications;
create policy write_utilisateurs on public.journal_modifications
  for insert to authenticated with check (public.current_utilisateur_id() is not null);

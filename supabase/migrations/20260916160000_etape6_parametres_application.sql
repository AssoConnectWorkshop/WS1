-- Étape 6 : paramètres d'application (brief §6.2, §6.3), éditables au paramétrage (CRUD générique : id + clé unique).
create table if not exists public.parametres_application (
  id bigint generated always as identity primary key,
  cle text not null unique,
  valeur text,
  libelle text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
select public.apply_set_updated_at('parametres_application');

insert into public.parametres_application (cle, valeur, libelle) values
  ('operateur_nom', 'FMC Maintenance', 'Opérateur (certificat d''étanchéité) : raison sociale'),
  ('operateur_adresse', '2 rue Galilée, 33185 Le Haillan', 'Opérateur : adresse'),
  ('operateur_siret', null, 'Opérateur : SIRET'),
  ('operateur_attestation', null, 'Opérateur : n° d''attestation de capacité (fluides frigorigènes)'),
  ('detecteur_fuites', 'TESTO 316-4', 'Détecteur de fuites utilisé pour les contrôles d''étanchéité'),
  ('email_sav', null, 'Adresse e-mail SAV destinataire des relances automatiques')
on conflict (cle) do nothing;

alter table public.parametres_application enable row level security;
drop policy if exists select_authenticated on public.parametres_application;
create policy select_authenticated on public.parametres_application for select to authenticated using (true);
drop policy if exists write_utilisateurs on public.parametres_application;
create policy write_utilisateurs on public.parametres_application
  for all to authenticated using (public.current_utilisateur_id() is not null) with check (public.current_utilisateur_id() is not null);

-- Journal des e-mails envoyés (relances automatiques et e-mails manuels, brief §6.3-6.4).
create table if not exists public.journal_emails (
  id bigint generated always as identity primary key,
  intervention_id bigint references public.interventions(id) on delete set null,
  destinataire text not null,
  objet text not null,
  type text not null,
  statut text not null,
  detail text,
  envoye_le timestamptz not null default now()
);
create index if not exists journal_emails_intervention_id_idx on public.journal_emails (intervention_id);
alter table public.journal_emails enable row level security;
drop policy if exists select_authenticated on public.journal_emails;
create policy select_authenticated on public.journal_emails for select to authenticated using (true);

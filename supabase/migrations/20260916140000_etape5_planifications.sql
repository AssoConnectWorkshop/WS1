-- Étape 5.4 : planifications saisies dans l'application (brief §5.4).
-- Une ligne par date limite ; un plan = client + lot + nombre de visites.
alter table public.planifications alter column legacy_id drop not null;
alter table public.planifications add column if not exists lot text not null default 'clim';
alter table public.planifications add column if not exists reference_client text;
select public.add_constraint_if_not_exists('planifications', 'planifications_lot_check', 'check (lot in (''clim'',''chaudiere'',''desenfumage''))');
create unique index if not exists planifications_app_idx on public.planifications (client_id, lot, nombre_visites, rang) where legacy_id is null;
comment on column public.planifications.reference_client is 'Référence de demande d''intervention (DI) client reprise sur chaque entretien généré pour cette date (source : DIENTn).';

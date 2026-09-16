-- Étape 5.2 : les devis créés dans l'application n'ont pas d'identifiant Access.
-- unique (famille, legacy_id) reste valide : plusieurs NULL sont autorisés par Postgres.
alter table public.devis alter column legacy_id drop not null;

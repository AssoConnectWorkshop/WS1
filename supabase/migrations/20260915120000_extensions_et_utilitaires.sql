-- Fonctions utilitaires communes à toutes les migrations de l'étape 1 (schéma ClimAccess).

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Applique le trigger set_updated_at à une table donnée (idempotent via "create or replace trigger").
create or replace function public.apply_set_updated_at(target_table text)
returns void
language plpgsql
as $$
begin
  execute format(
    'create or replace trigger set_updated_at before update on public.%I for each row execute function public.set_updated_at()',
    target_table
  );
end;
$$;

-- Ajoute une contrainte (FK notamment) seulement si elle n'existe pas déjà : permet de
-- déclarer une clé étrangère vers une table créée plus tard dans l'ordre des migrations
-- sans échouer en cas de rejeu.
create or replace function public.add_constraint_if_not_exists(
  target_table text,
  constraint_name text,
  constraint_definition text
)
returns void
language plpgsql
as $$
begin
  if not exists (select 1 from pg_constraint where conname = constraint_name) then
    execute format('alter table public.%I add constraint %I %s', target_table, constraint_name, constraint_definition);
  end if;
end;
$$;

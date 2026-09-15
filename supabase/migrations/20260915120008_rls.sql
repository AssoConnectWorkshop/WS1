-- RLS : lecture ouverte aux utilisateurs authentifiés, écriture réservée aux utilisateurs
-- connus de la table utilisateurs, suppression et écriture des référentiels réservées au
-- rôle administrateur. Le service role (script de migration) contourne RLS par nature.

create or replace function public.current_utilisateur_id()
returns bigint
language sql
stable
security definer
set search_path = public
as $$
  select id from public.utilisateurs where auth_user_id = auth.uid();
$$;

create or replace function public.current_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role from public.utilisateurs where auth_user_id = auth.uid();
$$;

do $$
declare
  t text;
  referentiels text[] := array[
    'statuts_intervention', 'types_intervention', 'statuts_facturation', 'sous_types_intervention',
    'natures_visite', 'pannes', 'modes_resolution', 'types_fluide', 'familles_gaz', 'marques',
    'references_materiel', 'reperes', 'types_telecommande', 'types_equipement', 'activites',
    'zones_geographiques', 'societes', 'jours_feries', 'ecarts_visites', 'types_evenement_vehicule',
    'etats_vehicule', 'statuts_devis'
  ];
begin
  for t in
    select tablename from pg_tables
    where schemaname = 'public'
      and tablename not like 'ws1_%'
      and tablename <> 'schema_migrations'
  loop
    execute format('alter table public.%I enable row level security', t);

    execute format('drop policy if exists select_authenticated on public.%I', t);
    execute format(
      'create policy select_authenticated on public.%I for select to authenticated using (true)',
      t
    );

    execute format('drop policy if exists delete_administrateur on public.%I', t);
    execute format(
      'create policy delete_administrateur on public.%I for delete to authenticated using (public.current_role() = ''administrateur'')',
      t
    );

    if t = any(referentiels) then
      execute format('drop policy if exists write_administrateur on public.%I', t);
      execute format(
        'create policy write_administrateur on public.%I for insert to authenticated with check (public.current_role() = ''administrateur'')',
        t
      );
      execute format('drop policy if exists update_administrateur on public.%I', t);
      execute format(
        'create policy update_administrateur on public.%I for update to authenticated using (public.current_role() = ''administrateur'') with check (public.current_role() = ''administrateur'')',
        t
      );
    else
      execute format('drop policy if exists write_utilisateurs on public.%I', t);
      execute format(
        'create policy write_utilisateurs on public.%I for insert to authenticated with check (public.current_utilisateur_id() is not null)',
        t
      );
      execute format('drop policy if exists update_utilisateurs on public.%I', t);
      execute format(
        'create policy update_utilisateurs on public.%I for update to authenticated using (public.current_utilisateur_id() is not null) with check (public.current_utilisateur_id() is not null)',
        t
      );
    end if;
  end loop;
end $$;

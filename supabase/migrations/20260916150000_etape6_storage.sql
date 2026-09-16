-- Étape 6 : buckets Storage privés (bons d'intervention, certificats d'étanchéité, logos).
-- Écriture et lecture par le serveur (clé service role) ; le schéma storage n'existe que sur Supabase.
do $$
begin
  if exists (select 1 from information_schema.schemata where schema_name = 'storage') then
    insert into storage.buckets (id, name, public)
    values ('bons', 'bons', false), ('certificats', 'certificats', false), ('logos', 'logos', false)
    on conflict (id) do nothing;
  end if;
end $$;

-- Étape 8 : ordre des listes identique à Access. SQL Server (collation French_CI_AS) trie « par mots » :
-- ponctuation ignorée, insensible à la casse et aux accents. Postgres trie les caractères tels quels,
-- d'où « ????? », « (… », « 0- » en tête chez nous. Clé de tri normalisée pour sites et clients.
create extension if not exists unaccent;

-- Le schéma de l'extension dépend de l'installation (public ou extensions sur Supabase) : on le résout.
do $$
declare
  schema_unaccent text;
begin
  select n.nspname into schema_unaccent
  from pg_extension e join pg_namespace n on n.oid = e.extnamespace
  where e.extname = 'unaccent';

  execute format($f$
    create or replace function public.cle_tri(texte text)
    returns text
    language sql
    immutable
    parallel safe
    as $body$
      select nullif(trim(regexp_replace(lower(%1$I.unaccent(%2$L::regdictionary, coalesce(texte, ''))), '[^[:alnum:]]+', ' ', 'g')), '');
    $body$;
  $f$, schema_unaccent, schema_unaccent || '.unaccent');
end $$;
comment on function public.cle_tri is 'Clé de tri façon SQL Server French_CI_AS : sans accents, sans ponctuation, minuscules.';

alter table public.sites add column if not exists nom_tri text generated always as (public.cle_tri(nom)) stored;
create index if not exists sites_nom_tri_idx on public.sites (nom_tri);
alter table public.clients add column if not exists nom_tri text generated always as (public.cle_tri(nom)) stored;
create index if not exists clients_nom_tri_idx on public.clients (nom_tri);

create or replace view public.v_sites_liste as
select
  s.id,
  s.legacy_id,
  s.numero_magasin,
  s.code_client,
  s.nom,
  s.adresse,
  s.code_postal,
  s.ville,
  s.telephone,
  s.longitude,
  s.latitude,
  s.particulier,
  s.investissement,
  s.retard_paiement,
  s.ne_plus_intervenir,
  s.ferme,
  s.zone_id,
  s.donneur_ordre_id,
  c.id as client_id,
  c.nom as client_nom,
  c.tarif_heure_mo as client_tarif_heure_mo,
  c.tarif_deplacement as client_tarif_deplacement,
  z.libelle as zone_libelle,
  iv.id as intervenant_id,
  iv.nom as intervenant_nom,
  sc.numero_contrat as contrat_clim_numero,
  sc.visites_par_an as contrat_clim_visites_par_an,
  sc.redevance as contrat_clim_redevance,
  sc.sous_traitant_id as contrat_clim_sous_traitant_id,
  s.date_derniere_visite_entretien,
  s.rdv_a_prendre,
  d.nom as donneur_ordre_nom,
  sc.redevance_secondaire as contrat_clim_redevance_secondaire,
  s.commentaire_general,
  s.precision_geo,
  s.dossier_chemin,
  s.nom_tri,
  c.nom_tri as client_nom_tri
from public.sites s
join public.clients c on c.id = s.client_id
left join public.zones_geographiques z on z.id = s.zone_id
left join public.intervenants iv on iv.id = s.intervenant_id
left join public.donneurs_ordre d on d.id = s.donneur_ordre_id
left join public.site_contrats sc on sc.site_id = s.id and sc.lot = 'clim'
where c.actif is true;
